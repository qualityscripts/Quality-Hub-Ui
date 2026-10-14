local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Flipper = require(Root.Packages.Flipper)
local Creator = require(Root.Creator)

local Spring = Flipper.Spring.new
local New = Creator.New

local function F(Weight)
	return Font.new("rbxasset://fonts/families/BuilderSans.json", Weight or Enum.FontWeight.Regular)
end

local Notification = {}

function Notification:Init(GUI)
	Notification.Holder = New("Frame", {
		Position = UDim2.new(1, -24, 1, -24),
		Size = UDim2.new(0, 310, 1, -24),
		AnchorPoint = Vector2.new(1, 1),
		BackgroundTransparency = 1,
		Parent = GUI,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 12),
		}),
	})
end

function Notification:New(Config)
	local Library = require(Root)
	Config.Title = Config.Title or "Title"
	Config.Content = Config.Content or "Content"
	Config.SubContent = Config.SubContent or ""
	local NewNotification = {
		Closed = false,
	}

	NewNotification.Title = New("TextLabel", {
		Text = Config.Title,
		RichText = true,
		FontFace = F(Enum.FontWeight.Bold),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -30, 0, 18),
		LayoutOrder = 1,
		ThemeTag = { TextColor3 = "Text" },
	})

	NewNotification.ContentLabel = New("TextLabel", {
		Text = Config.Content,
		FontFace = F(Enum.FontWeight.Medium),
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 2,
		Visible = Config.Content ~= "",
		ThemeTag = { TextColor3 = "Text" },
	})

	NewNotification.SubContentLabel = New("TextLabel", {
		Text = Config.SubContent,
		FontFace = F(Enum.FontWeight.Medium),
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 13),
		LayoutOrder = 3,
		Visible = Config.SubContent ~= "",
		ThemeTag = { TextColor3 = "SubText" },
	})

	NewNotification.CloseButton = New("TextButton", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(1, -12, 0, 12),
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, {
		New("ImageLabel", {
			Image = Library:GetIcon("x"),
			Size = UDim2.fromOffset(15, 15),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 3,
			ThemeTag = { ImageColor3 = "TabText" },
		}),
	})

	local Progress = New("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		ZIndex = 2,
		Visible = Config.Duration ~= nil,
		ThemeTag = { BackgroundColor3 = "Accent" },
	})

	NewNotification.Card = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		ThemeTag = { BackgroundColor3 = "NotificationBg" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1.5,
			ThemeTag = { Color = "UIOutline" },
		}),
		New("Frame", {
			Size = UDim2.new(0, 3, 1, -24),
			Position = UDim2.fromOffset(0, 12),
			ZIndex = 2,
			ThemeTag = { BackgroundColor3 = "Accent" },
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		}),
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, {
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 14),
				PaddingTop = UDim.new(0, 14),
				PaddingBottom = UDim.new(0, 16),
			}),
			New("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 5),
			}),
			NewNotification.Title,
			NewNotification.ContentLabel,
			NewNotification.SubContentLabel,
		}),
		NewNotification.CloseButton,
		Progress,
	})

	NewNotification.Root = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(1, 0),
	}, {
		NewNotification.Card,
	})

	NewNotification.Holder = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = Notification.Holder,
	}, {
		NewNotification.Root,
	})

	local RootMotor = Flipper.GroupMotor.new({
		Scale = 1,
		Offset = 60,
	})

	RootMotor:onStep(function(Values)
		NewNotification.Root.Position = UDim2.new(Values.Scale, Values.Offset, 0, 0)
	end)

	Creator.AddSignal(NewNotification.CloseButton.MouseButton1Click, function()
		NewNotification:Close()
	end)

	Creator.AddSignal(NewNotification.Card:GetPropertyChangedSignal("AbsoluteSize"), function()
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, NewNotification.Card.AbsoluteSize.Y)
	end)

	function NewNotification:Open()
		NewNotification.Holder.Size = UDim2.new(1, 0, 0, NewNotification.Card.AbsoluteSize.Y)
		RootMotor:setGoal({
			Scale = Spring(0, { frequency = 5 }),
			Offset = Spring(0, { frequency = 5 }),
		})
	end

	function NewNotification:Close()
		if not NewNotification.Closed then
			NewNotification.Closed = true
			task.spawn(function()
				RootMotor:setGoal({
					Scale = Spring(1, { frequency = 5 }),
					Offset = Spring(60, { frequency = 5 }),
				})
				task.wait(0.4)
				NewNotification.Holder:Destroy()
			end)
		end
	end

	NewNotification:Open()
	if Config.Duration then
		TweenService:Create(Progress, TweenInfo.new(Config.Duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 0, 2),
		}):Play()
		task.delay(Config.Duration, function()
			NewNotification:Close()
		end)
	end
	return NewNotification
end

return Notification
