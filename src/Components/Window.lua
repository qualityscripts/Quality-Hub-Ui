local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)
local Components = script.Parent

local Instant = Flipper.Instant.new
local New = Creator.New

local function F(Weight)
	return Font.new("rbxasset://fonts/families/BuilderSans.json", Weight or Enum.FontWeight.Regular)
end

local function MaskName(Name)
	if #Name <= 2 then
		return Name
	end
	return Name:sub(1, 2) .. string.rep("*", math.min(#Name - 2, 12))
end

return function(Config)
	local Library = require(Root)
	local LocalPlayer = Players.LocalPlayer

	local Window = {
		Minimized = false,
		Maximized = false,
		Size = Config.Size,
		TabWidth = Config.TabWidth,
		Categories = {},
		LayoutCounter = 0,
		SearchQuery = "",
		Position = UDim2.fromOffset(
			Camera.ViewportSize.X / 2 - Config.Size.X.Offset / 2,
			Camera.ViewportSize.Y / 2 - Config.Size.Y.Offset / 2
		),
	}

	local Dragging, DragInput, MousePos, StartPos = false
	local Resizing, ResizePos = false
	local MinimizeNotif = false

	-- Sidebar ---------------------------------------------------------------

	local SidebarHeader = New("Frame", {
		Size = UDim2.new(1, 0, 0, 70),
		BackgroundTransparency = 1,
	}, {
		New("TextLabel", {
			Text = Config.Title,
			FontFace = F(Enum.FontWeight.Bold),
			TextSize = 22,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -36, 0, 24),
			Position = UDim2.fromOffset(20, 18),
			TextTruncate = Enum.TextTruncate.AtEnd,
			ThemeTag = { TextColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Config.SubTitle or "",
			FontFace = F(Enum.FontWeight.Medium),
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, -36, 0, 14),
			Position = UDim2.fromOffset(20, 42),
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})

	Window.TabHolder = New("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -70 - 64),
		Position = UDim2.fromOffset(0, 70),
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		New("UIPadding", {
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 8),
		}),
	})

	local Avatar = New("ImageLabel", {
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.new(0, 18, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 0,
		Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150",
		ThemeTag = { BackgroundColor3 = "ControlBg" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local DisplayName = Config.HideName == false and LocalPlayer.Name or MaskName(LocalPlayer.Name)

	local Profile = New("Frame", {
		Size = UDim2.new(1, 0, 0, 64),
		Position = UDim2.new(0, 0, 1, -64),
		BackgroundTransparency = 1,
	}, {
		New("Frame", {
			Size = UDim2.new(1, -32, 0, 1),
			Position = UDim2.fromOffset(16, 0),
			ThemeTag = { BackgroundColor3 = "Divider" },
		}),
		Avatar,
		New("TextLabel", {
			Text = DisplayName,
			FontFace = F(Enum.FontWeight.SemiBold),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -72, 0, 16),
			Position = UDim2.new(0, 62, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ThemeTag = { TextColor3 = "Text" },
		}),
	})

	local Sidebar = New("Frame", {
		Size = UDim2.new(0, Window.TabWidth, 1, 0),
		BackgroundTransparency = 1,
	}, {
		SidebarHeader,
		Window.TabHolder,
		Profile,
		New("Frame", {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
			ThemeTag = { BackgroundColor3 = "Divider" },
		}),
	})

	-- Top bar -------------------------------------------------------------

	Window.TabDisplay = New("TextLabel", {
		RichText = true,
		Text = "",
		FontFace = F(Enum.FontWeight.Bold),
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -300, 1, 0),
		Position = UDim2.fromOffset(22, 0),
		ThemeTag = { TextColor3 = "Text" },
	})

	local SearchBox = New("TextBox", {
		FontFace = F(Enum.FontWeight.Medium),
		PlaceholderText = "search...",
		Text = "",
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -38, 1, 0),
		Position = UDim2.fromOffset(32, 0),
		ClearTextOnFocus = false,
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	local SearchFrame = New("Frame", {
		Size = UDim2.fromOffset(170, 32),
		Position = UDim2.new(1, -74, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { BackgroundColor3 = "SearchBg" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 8) }),
		New("ImageLabel", {
			Image = Library:GetIcon("search"),
			Size = UDim2.fromOffset(15, 15),
			Position = UDim2.new(0, 11, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ThemeTag = { ImageColor3 = "SubText" },
		}),
		SearchBox,
	})

	local function TopButton(Icon, XOffset, Callback)
		local Button = New("TextButton", {
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.new(1, XOffset, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			ThemeTag = { BackgroundColor3 = "ControlHover" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(0, 6) }),
			New("ImageLabel", {
				Image = Library:GetIcon(Icon),
				Size = UDim2.fromOffset(15, 15),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ThemeTag = { ImageColor3 = "SubText" },
			}),
		})
		Creator.AddSignal(Button.MouseEnter, function()
			Button.BackgroundTransparency = 0
		end)
		Creator.AddSignal(Button.MouseLeave, function()
			Button.BackgroundTransparency = 1
		end)
		Creator.AddSignal(Button.MouseButton1Click, Callback)
		return Button
	end

	local TopBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundTransparency = 1,
	}, {
		Window.TabDisplay,
		SearchFrame,
		TopButton("minus", -44, function()
			Window:Minimize()
		end),
		TopButton("x", -14, function()
			Window:Dialog({
				Title = "Close",
				Content = "Are you sure you want to unload the interface?",
				Buttons = {
					{ Title = "Yes", Callback = function() Library:Destroy() end },
					{ Title = "No" },
				},
			})
		end),
	})

	-- Content ---------------------------------------------------------------

	Window.ContainerHolder = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerAnim = New("CanvasGroup", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	})

	Window.ContainerCanvas = New("Frame", {
		Size = UDim2.new(1, 0, 1, -62),
		Position = UDim2.fromOffset(0, 62),
		BackgroundTransparency = 1,
	}, {
		Window.ContainerAnim,
		Window.ContainerHolder,
	})

	local Main = New("Frame", {
		Size = UDim2.new(1, -Window.TabWidth, 1, 0),
		Position = UDim2.fromOffset(Window.TabWidth, 0),
		BackgroundTransparency = 1,
	}, {
		TopBar,
		Window.ContainerCanvas,
	})

	local ResizeStartFrame = New("ImageButton", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(1, -18, 1, -18),
		BackgroundTransparency = 1,
		ZIndex = 5,
	}, {
		New("TextLabel", {
			Text = "⌟",
			TextSize = 16,
			Size = UDim2.fromScale(1, 1),
			TextTransparency = 0.5,
			ThemeTag = { TextColor3 = "SubText" },
		}),
	})

	Window.Root = New("Frame", {
		Size = Window.Size,
		Position = Window.Position,
		Parent = Config.Parent,
		ThemeTag = { BackgroundColor3 = "Background" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "WindowBorder" },
		}),
		Sidebar,
		Main,
		ResizeStartFrame,
	})

	-- Kept for compatibility with code expecting Window.TitleBar.Frame
	Window.TitleBar = { Frame = TopBar }

	-- Search ----------------------------------------------------------------

	function Window:ApplySearch()
		local TabModule = require(Components.Tab)
		local Container = TabModule.Containers[TabModule.SelectedTab]
		if not Container then
			return
		end
		local Query = Window.SearchQuery:lower()

		for _, Object in next, Container:GetDescendants() do
			local Title = Object:GetAttribute("SearchTitle")
			if Title then
				Object.Visible = Query == "" or Title:lower():find(Query, 1, true) ~= nil
			end
		end

		for _, Object in next, Container:GetDescendants() do
			local SectionTitle = Object:GetAttribute("SearchSection")
			if SectionTitle then
				if Query == "" or SectionTitle:lower():find(Query, 1, true) then
					Object.Visible = true
					if Query ~= "" then
						for _, Child in next, Object:GetDescendants() do
							if Child:GetAttribute("SearchTitle") then
								Child.Visible = true
							end
						end
					end
				else
					local Any = false
					for _, Child in next, Object:GetDescendants() do
						if Child:GetAttribute("SearchTitle") and Child.Visible then
							Any = true
							break
						end
					end
					Object.Visible = Any
				end
			end
		end
	end

	Creator.AddSignal(SearchBox:GetPropertyChangedSignal("Text"), function()
		Window.SearchQuery = SearchBox.Text
		Window:ApplySearch()
	end)

	-- Motors ----------------------------------------------------------------

	local SizeMotor = Flipper.GroupMotor.new({
		X = Window.Size.X.Offset,
		Y = Window.Size.Y.Offset,
	})

	local PosMotor = Flipper.GroupMotor.new({
		X = Window.Position.X.Offset,
		Y = Window.Position.Y.Offset,
	})

	Window.ContainerBackMotor = Flipper.SingleMotor.new(0)
	Window.ContainerPosMotor = Flipper.SingleMotor.new(94)

	SizeMotor:onStep(function(values)
		Window.Root.Size = UDim2.new(0, values.X, 0, values.Y)
	end)

	PosMotor:onStep(function(values)
		Window.Root.Position = UDim2.new(0, values.X, 0, values.Y)
	end)

	Window.ContainerBackMotor:onStep(function(Value)
		Window.ContainerAnim.GroupTransparency = Value
	end)

	Window.ContainerPosMotor:onStep(function(Value)
		Window.ContainerAnim.Position = UDim2.fromOffset(0, Value)
	end)

	-- Dragging / resizing -------------------------------------------------

	local function HookDrag(Handle)
		Creator.AddSignal(Handle.InputBegan, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Dragging = true
				MousePos = Input.Position
				StartPos = Window.Root.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Creator.AddSignal(Handle.InputChanged, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				DragInput = Input
			end
		end)
	end

	HookDrag(TopBar)
	HookDrag(SidebarHeader)

	Creator.AddSignal(ResizeStartFrame.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Resizing = true
			ResizePos = Input.Position
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			Window.Position = UDim2.fromOffset(StartPos.X.Offset + Delta.X, StartPos.Y.Offset + Delta.Y)
			PosMotor:setGoal({
				X = Instant(Window.Position.X.Offset),
				Y = Instant(Window.Position.Y.Offset),
			})
		end

		if
			(Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch)
			and Resizing
		then
			local Delta = Input.Position - ResizePos
			local StartSize = Window.Size

			local TargetSize = Vector3.new(StartSize.X.Offset, StartSize.Y.Offset, 0) + Vector3.new(1, 1, 0) * Delta
			local TargetSizeClamped =
				Vector2.new(math.clamp(TargetSize.X, 560, 2048), math.clamp(TargetSize.Y, 360, 2048))

			SizeMotor:setGoal({
				X = Instant(TargetSizeClamped.X),
				Y = Instant(TargetSizeClamped.Y),
			})
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if Resizing == true or Input.UserInputType == Enum.UserInputType.Touch then
			Resizing = false
			Window.Size = UDim2.fromOffset(SizeMotor:getValue().X, SizeMotor:getValue().Y)
		end
	end)

	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			type(Library.MinimizeKeybind) == "table"
			and Library.MinimizeKeybind.Type == "Keybind"
			and not UserInputService:GetFocusedTextBox()
		then
			if Input.KeyCode.Name == Library.MinimizeKeybind.Value then
				Window:Minimize()
			end
		elseif Input.KeyCode == Library.MinimizeKey and not UserInputService:GetFocusedTextBox() then
			Window:Minimize()
		end
	end)

	function Window:Minimize()
		Window.Minimized = not Window.Minimized
		Window.Root.Visible = not Window.Minimized
		if not MinimizeNotif then
			MinimizeNotif = true
			local Key = Library.MinimizeKeybind and Library.MinimizeKeybind.Value or Library.MinimizeKey.Name
			Library:Notify({
				Title = "Interface",
				Content = "Press " .. Key .. " to toggle the interface.",
				Duration = 6,
			})
		end
	end

	function Window:SetTransparency(Value)
		Window.Root.BackgroundTransparency = Value and 0.15 or 0
	end

	function Window:Destroy()
		Window.Root:Destroy()
	end

	-- Dialogs -----------------------------------------------------------------

	local DialogModule = require(Components.Dialog):Init(Window)
	function Window:Dialog(DialogConfig)
		local Dialog = DialogModule:Create()
		Dialog.Title.Text = DialogConfig.Title

		local Content = New("TextLabel", {
			FontFace = F(),
			Text = DialogConfig.Content,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.fromOffset(20, 60),
			Parent = Dialog.Root,
			ClipsDescendants = false,
			ThemeTag = { TextColor3 = "Text" },
		})

		New("UISizeConstraint", {
			MinSize = Vector2.new(300, 165),
			MaxSize = Vector2.new(620, math.huge),
			Parent = Dialog.Root,
		})

		Dialog.Root.Size = UDim2.fromOffset(Content.TextBounds.X + 40, 165)
		if Content.TextBounds.X + 40 > Window.Size.X.Offset - 120 then
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, 165)
			Content.TextWrapped = true
			Dialog.Root.Size = UDim2.fromOffset(Window.Size.X.Offset - 120, Content.TextBounds.Y + 150)
		end

		for _, Button in next, DialogConfig.Buttons do
			Dialog:Button(Button.Title, Button.Callback)
		end

		Dialog:Open()
	end

	-- Categories & tabs -----------------------------------------------------

	local function NextOrder()
		Window.LayoutCounter = Window.LayoutCounter + 1
		return Window.LayoutCounter
	end

	local TabModule = require(Components.Tab):Init(Window)

	function Window:AddCategory(Title)
		if Window.Categories[Title] then
			return Window.Categories[Title]
		end

		local Category = { Title = Title, Collapsed = false }

		local Chevron = New("ImageLabel", {
			Image = Library:GetIcon("chevron-down"),
			Size = UDim2.fromOffset(15, 15),
			Position = UDim2.new(1, -8, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			ThemeTag = { ImageColor3 = "CategoryText" },
		})

		local Header = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, {
			New("TextLabel", {
				Text = Title,
				FontFace = F(Enum.FontWeight.SemiBold),
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.fromOffset(20, 0),
				ThemeTag = { TextColor3 = "CategoryText" },
			}),
			Chevron,
		})

		Category.TabList = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		Category.Frame = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = NextOrder(),
			Parent = Window.TabHolder,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			New("UIPadding", { PaddingTop = UDim.new(0, 4) }),
			Header,
			Category.TabList,
		})

		Creator.AddSignal(Header.MouseButton1Click, function()
			Category.Collapsed = not Category.Collapsed
			Category.TabList.Visible = not Category.Collapsed
			Chevron.Rotation = Category.Collapsed and -90 or 0
		end)

		function Category:AddTab(TabConfig)
			TabConfig.Category = Title
			return Window:AddTab(TabConfig)
		end

		Window.Categories[Title] = Category
		return Category
	end

	function Window:AddTab(TabConfig)
		local Parent = Window.TabHolder
		local CategoryName = TabConfig.Category
		if CategoryName then
			Parent = Window:AddCategory(CategoryName).TabList
		end
		local Tab = TabModule:New(TabConfig.Title, TabConfig.Icon, Parent, CategoryName)
		Tab.Frame.LayoutOrder = NextOrder()
		return Tab
	end

	function Window:SelectTab(Tab)
		TabModule:SelectTab(Tab or 1)
	end

	return Window
end
