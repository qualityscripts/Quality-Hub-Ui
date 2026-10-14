local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local New = Creator.New

-- Layout (top to bottom): Header (title + inline controls), Control slot, Description.
return function(Title, Desc, Parent)
	local Element = {}

	Element.TitleLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
		Text = Title,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, 0, 1, 0),
		ThemeTag = { TextColor3 = "Text" },
	})

	Element.Header = New("Frame", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	}, {
		Element.TitleLabel,
	})

	Element.Control = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Visible = false,
	})

	Element.DescLabel = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
		Text = Desc or "",
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 14),
		LayoutOrder = 3,
		ThemeTag = { TextColor3 = "SubText" },
	})

	-- Fluent compatibility aliases
	Element.LabelHolder = Element.Header
	Element.Border = New("UIStroke", { Enabled = false, Transparency = 1 })

	Element.Frame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = 7,
		Parent = Parent,
	}, {
		New("UIListLayout", {
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Element.Header,
		Element.Control,
		Element.DescLabel,
		Element.Border,
	})
	Element.Frame:SetAttribute("SearchTitle", Title)

	function Element:UseControl()
		Element.Control.Visible = true
		return Element.Control
	end

	function Element:SetTitle(Set)
		Element.TitleLabel.Text = Set
		Element.Frame:SetAttribute("SearchTitle", Set)
	end

	function Element:SetDesc(Set)
		if Set == nil then
			Set = ""
		end
		Element.DescLabel.Visible = Set ~= ""
		Element.DescLabel.Text = Set
	end

	function Element:Destroy()
		Element.Frame:Destroy()
	end

	Element:SetTitle(Title)
	Element:SetDesc(Desc)

	return Element
end
