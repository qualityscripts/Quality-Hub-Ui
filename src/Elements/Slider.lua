local UserInputService = game:GetService("UserInputService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Slider"

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Slider - Missing Title.")
	assert(Config.Default, "Slider - Missing default value.")
	assert(Config.Min, "Slider - Missing minimum value.")
	assert(Config.Max, "Slider - Missing maximum value.")
	assert(Config.Rounding, "Slider - Missing rounding value.")

	local Slider = {
		Value = nil,
		Min = Config.Min,
		Max = Config.Max,
		Rounding = Config.Rounding,
		Suffix = Config.Suffix or "",
		Callback = Config.Callback or function(Value) end,
		Type = "Slider",
	}

	local Dragging = false

	local SliderFrame = require(Components.Element)(Config.Title, Config.Description, self.Container)
	SliderFrame.TitleLabel.Size = UDim2.new(1, -110, 1, 0)

	Slider.SetTitle = SliderFrame.SetTitle
	Slider.SetDesc = SliderFrame.SetDesc

	local SliderDisplay = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium),
		TextSize = 15,
		BackgroundTransparency = 1,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 110, 1, 0),
		Position = UDim2.fromScale(1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Parent = SliderFrame.Header,
		ThemeTag = { TextColor3 = "TabText" },
	})

	local GlowSpread = 12
	local SliderGlow = Creator.Glow(GlowSpread, 3, {
		Position = UDim2.fromOffset(-GlowSpread, -GlowSpread),
	})

	local SliderFill = New("Frame", {
		Size = UDim2.fromScale(0, 1),
		ZIndex = 2,
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local SliderDot = New("Frame", {
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		ZIndex = 3,
		ThemeTag = { BackgroundColor3 = "Accent" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local SliderRail = New("Frame", {
		Size = UDim2.new(1, 0, 0, 5),
		Position = UDim2.fromScale(0, 0.5),
		AnchorPoint = Vector2.new(0, 0.5),
		ThemeTag = { BackgroundColor3 = "SliderRail" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		SliderGlow,
		SliderFill,
		SliderDot,
	})

	local HitArea = New("Frame", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Parent = SliderFrame:UseControl(),
	}, {
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
		}),
		SliderRail,
	})

	local function UpdateFromInput(Input)
		local Scale = math.clamp((Input.Position.X - SliderRail.AbsolutePosition.X) / SliderRail.AbsoluteSize.X, 0, 1)
		Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * Scale))
	end

	Creator.AddSignal(HitArea.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = true
			UpdateFromInput(Input)
		end
	end)

	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			Dragging = false
		end
	end)

	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if
			Dragging
			and (
				Input.UserInputType == Enum.UserInputType.MouseMovement
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			UpdateFromInput(Input)
		end
	end)

	-- Click the value to type one; the suffix is optional and out-of-range numbers are clamped.
	Creator.AddSignal(SliderDisplay.Focused, function()
		SliderDisplay.Text = tostring(Slider.Value)
	end)
	Creator.AddSignal(SliderDisplay.FocusLost, function()
		local Number = tonumber((SliderDisplay.Text:gsub("[^%d%.%-]", "")))
		Slider:SetValue(Number or Slider.Value)
	end)

	function Slider:OnChanged(Func)
		Slider.Changed = Func
		Func(Slider.Value)
	end

	function Slider:SetValue(Value)
		self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
		local Scale = (self.Value - Slider.Min) / (Slider.Max - Slider.Min)
		SliderDot.Position = UDim2.fromScale(Scale, 0.5)
		SliderFill.Size = UDim2.fromScale(Scale, 1)
		SliderGlow.Size = UDim2.new(Scale, GlowSpread * 2 + 8, 1, GlowSpread * 2)

		local Text = Slider.Rounding > 0 and string.format("%." .. Slider.Rounding .. "f", self.Value)
			or tostring(self.Value)
		SliderDisplay.Text = Text .. Slider.Suffix

		Library:SafeCallback(Slider.Callback, self.Value)
		Library:SafeCallback(Slider.Changed, self.Value)
	end

	function Slider:Destroy()
		SliderFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Slider:SetValue(Config.Default)

	Library.Options[Idx] = Slider
	return Slider
end

return Element
