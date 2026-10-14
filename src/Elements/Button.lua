local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Button"

function Element:New(Config)
	assert(Config.Title, "Button - Missing Title")
	Config.Callback = Config.Callback or function() end

	local ButtonFrame = require(Components.Element)(Config.Title, Config.Description, self.Container)
	ButtonFrame.Header.Visible = false

	local Box = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		Text = Config.Title,
		FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.SemiBold),
		TextSize = 16,
		Parent = ButtonFrame:UseControl(),
		ThemeTag = {
			BackgroundColor3 = "ControlBg",
			TextColor3 = "Text",
		},
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 7) }),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = { Color = "ControlBorder" },
		}),
	})

	local SetTitle = ButtonFrame.SetTitle
	function ButtonFrame:SetTitle(Set)
		SetTitle(ButtonFrame, Set)
		Box.Text = Set
	end

	Creator.AddSignal(Box.MouseEnter, function()
		Creator.OverrideTag(Box, { BackgroundColor3 = "ControlHover", TextColor3 = "Text" })
	end)
	Creator.AddSignal(Box.MouseLeave, function()
		Creator.OverrideTag(Box, { BackgroundColor3 = "ControlBg", TextColor3 = "Text" })
	end)
	Creator.AddSignal(Box.MouseButton1Click, function()
		self.Library:SafeCallback(Config.Callback)
	end)

	return ButtonFrame
end

return Element
