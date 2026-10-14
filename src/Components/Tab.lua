local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local New = Creator.New
local Spring = Flipper.Spring.new
local Components = Root.Components

local TabModule = {
	Window = nil,
	Tabs = {},
	Containers = {},
	SelectedTab = 0,
	TabCount = 0,
}

function TabModule:Init(Window)
	TabModule.Window = Window
	return TabModule
end

function TabModule:New(Title, Icon, Parent, Category)
	local Library = require(Root)
	local Window = TabModule.Window
	local Elements = Library.Elements

	TabModule.TabCount = TabModule.TabCount + 1
	local TabIndex = TabModule.TabCount

	local Tab = {
		Selected = false,
		Name = Title,
		Category = Category,
		Type = "Tab",
		SectionCount = 0,
	}

	if Library:GetIcon(Icon) then
		Icon = Library:GetIcon(Icon)
	end
	if Icon == "" then
		Icon = nil
	end

	local Highlight = New("Frame", {
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		ThemeTag = { BackgroundColor3 = "TabSelected" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 7) }),
	})

	local Indicator = New("Frame", {
		Size = UDim2.fromOffset(3, 22),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local Label = New("TextLabel", {
		Text = Title,
		RichText = true,
		FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, Icon and -56 or -30, 1, 0),
		Position = UDim2.fromOffset(Icon and 50 or 24, 0),
		ThemeTag = { TextColor3 = "TabText" },
	})

	local IconLabel = New("ImageLabel", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(0, 22, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Image = Icon or "",
		Visible = Icon ~= nil,
		ThemeTag = { ImageColor3 = "TabText" },
	})

	Tab.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		Parent = Parent,
	}, {
		Highlight,
		Indicator,
		IconLabel,
		Label,
	})

	Tab.Highlight = Highlight
	Tab.Indicator = Indicator
	Tab.Label = Label
	Tab.IconLabel = IconLabel

	local function Paint()
		local Hovered = Tab.Hovered and not Tab.Selected
		Highlight.BackgroundTransparency = Tab.Selected and 0 or (Hovered and 0.5 or 1)
		Indicator.BackgroundTransparency = Tab.Selected and 0 or 1
		local Color = Tab.Selected and "Text" or "TabText"
		Creator.OverrideTag(Label, { TextColor3 = Color })
		Creator.OverrideTag(IconLabel, { ImageColor3 = Color })
	end
	Tab.Paint = Paint

	Creator.AddSignal(Tab.Frame.MouseEnter, function()
		Tab.Hovered = true
		Paint()
	end)
	Creator.AddSignal(Tab.Frame.MouseLeave, function()
		Tab.Hovered = false
		Paint()
	end)
	Creator.AddSignal(Tab.Frame.MouseButton1Click, function()
		TabModule:SelectTab(TabIndex)
	end)

	-- Content: two columns of section cards
	local function Column(Order)
		return New("Frame", {
			Size = UDim2.new(0.5, -7, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, {
			New("UIListLayout", {
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})
	end

	Tab.LeftColumn = Column(1)
	Tab.RightColumn = Column(2)

	Tab.ContainerFrame = New("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = Window.ContainerHolder,
		Visible = false,
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.9,
		ScrollBarThickness = 3,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 14),
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 2),
			PaddingBottom = UDim.new(0, 20),
		}),
		Tab.LeftColumn,
		Tab.RightColumn,
	})

	TabModule.Containers[TabIndex] = Tab.ContainerFrame
	TabModule.Tabs[TabIndex] = Tab

	-- Elements added straight to a tab land in the left column.
	Tab.Container = Tab.LeftColumn
	Tab.ScrollFrame = Tab.ContainerFrame

	-- AddSection("Title") or AddSection({ Title, Icon, Side = "Left"/"Right" })
	function Tab:AddSection(SectionConfig, SectionIcon)
		if type(SectionConfig) ~= "table" then
			SectionConfig = { Title = SectionConfig, Icon = SectionIcon }
		end

		Tab.SectionCount = Tab.SectionCount + 1
		local Side = SectionConfig.Side
		if Side == nil then
			Side = Tab.SectionCount % 2 == 1 and "Left" or "Right"
		end
		local ParentColumn = Side == "Right" and Tab.RightColumn or Tab.LeftColumn

		local Section = { Type = "Section" }
		local SectionFrame = require(Components.Section)(SectionConfig.Title, SectionConfig.Icon, ParentColumn)
		SectionFrame.Root.LayoutOrder = Tab.SectionCount
		Section.Container = SectionFrame.Container
		Section.ScrollFrame = Tab.ContainerFrame
		Section.Frame = SectionFrame

		function Section:SetCollapsed(Value)
			SectionFrame:SetCollapsed(Value)
		end

		setmetatable(Section, Elements)
		return Section
	end

	Paint()
	setmetatable(Tab, Elements)
	return Tab
end

function TabModule:SelectTab(Index)
	local Window = TabModule.Window
	local Selected = TabModule.Tabs[Index]
	if not Selected then
		return
	end

	TabModule.SelectedTab = Index

	for _, TabObject in next, TabModule.Tabs do
		TabObject.Selected = false
		TabObject.Paint()
	end
	Selected.Selected = true
	Selected.Paint()

	if Selected.Category then
		Window.TabDisplay.Text = Selected.Category .. "  <font transparency=\"0.4\">›</font>  " .. Selected.Name
	else
		Window.TabDisplay.Text = Selected.Name
	end

	task.spawn(function()
		Window.ContainerHolder.Parent = Window.ContainerAnim

		Window.ContainerPosMotor:setGoal(Spring(15, { frequency = 10 }))
		Window.ContainerBackMotor:setGoal(Spring(1, { frequency = 10 }))
		task.wait(0.12)
		for _, Container in next, TabModule.Containers do
			Container.Visible = false
		end
		TabModule.Containers[Index].Visible = true
		Window:ApplySearch()
		Window.ContainerPosMotor:setGoal(Spring(0, { frequency = 5 }))
		Window.ContainerBackMotor:setGoal(Spring(0, { frequency = 8 }))
		task.wait(0.12)
		Window.ContainerHolder.Parent = Window.ContainerCanvas
	end)
end

return TabModule
