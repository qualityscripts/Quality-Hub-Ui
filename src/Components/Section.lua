local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New

return function(Title, Icon, Parent)
	local Library = require(Root)
	local Section = { Collapsed = false }

	if Icon and Library:GetIcon(Icon) then
		Icon = Library:GetIcon(Icon)
	end
	if Icon == "" then
		Icon = nil
	end

	local Chevron = New("ImageLabel", {
		Image = Library:GetIcon("chevron-down"),
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.new(1, -16, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		ThemeTag = { ImageColor3 = "SubText" },
	})

	local Header = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, {
		New("ImageLabel", {
			Image = Icon or "",
			Visible = Icon ~= nil,
			Size = UDim2.fromOffset(20, 20),
			Position = UDim2.new(0, 18, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			ThemeTag = { ImageColor3 = "Text" },
		}),
		New("TextLabel", {
			Text = Title,
			RichText = true,
			FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Bold),
			TextSize = 17,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, Icon and -84 or -58, 1, 0),
			Position = UDim2.fromOffset(Icon and 48 or 18, 0),
			ThemeTag = { TextColor3 = "Text" },
		}),
		Chevron,
	})

	local Divider = New("Frame", {
		Size = UDim2.new(1, -28, 0, 1),
		Position = UDim2.fromOffset(14, 0),
		ThemeTag = { BackgroundColor3 = "Divider" },
	})

	local DividerHolder = New("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	}, {
		Divider,
	})

	Section.Layout = New("UIListLayout", {
		Padding = UDim.new(0, 16),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Section.Container = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	}, {
		Section.Layout,
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 18),
			PaddingRight = UDim.new(0, 18),
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 18),
		}),
	})

	Section.Root = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = Parent,
		ThemeTag = { BackgroundColor3 = "SectionBg" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 10) }),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "SectionBorder" },
		}),
		New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }),
		Header,
		DividerHolder,
		Section.Container,
	})
	Section.Root:SetAttribute("SearchSection", Title)

	function Section:SetCollapsed(Value)
		Section.Collapsed = Value
		Section.Container.Visible = not Value
		DividerHolder.Visible = not Value
		TweenService:Create(
			Chevron,
			TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Rotation = Value and -90 or 0 }
		):Play()
	end

	Creator.AddSignal(Header.MouseButton1Click, function()
		Section:SetCollapsed(not Section.Collapsed)
	end)

	return Section
end
