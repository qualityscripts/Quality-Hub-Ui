local TweenService = game:GetService("TweenService")
local Root = script.Parent.Parent
local Creator = require(Root.Creator)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Toggle"

local TweenFast = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

function Element:New(Idx, Config)
	local Library = self.Library
	assert(Config.Title, "Toggle - Missing Title")

	local Toggle = {
		Value = Config.Default or false,
		Callback = Config.Callback or function(Value) end,
		Type = "Toggle",
	}

	local ToggleFrame = require(Components.Element)(Config.Title, Config.Description, self.Container)
	ToggleFrame.TitleLabel.Position = UDim2.fromOffset(32, 0)
	ToggleFrame.TitleLabel.Size = UDim2.new(1, -32, 1, 0)
	ToggleFrame.Header.Size = UDim2.new(1, 0, 0, 22)

	Toggle.SetTitle = ToggleFrame.SetTitle
	Toggle.SetDesc = ToggleFrame.SetDesc

	local Check = New("ImageLabel", {
		Image = Library:GetIcon("check"),
		Size = UDim2.fromOffset(14, 14),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageTransparency = 1,
		ThemeTag = { ImageColor3 = "CheckboxCheck" },
	})

	local BoxStroke = New("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		ThemeTag = { Color = "CheckboxBorder" },
	})

	local Box = New("Frame", {
		Size = UDim2.fromOffset(22, 22),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Parent = ToggleFrame.Header,
		ThemeTag = { BackgroundColor3 = "CheckboxBg" },
	}, {
		New("UICorner", { CornerRadius = UDim.new(0, 6) }),
		BoxStroke,
		Check,
	})

	function Toggle:OnChanged(Func)
		Toggle.Changed = Func
		Func(Toggle.Value)
	end

	function Toggle:SetValue(Value)
		Value = not not Value
		Toggle.Value = Value

		Creator.OverrideTag(Box, { BackgroundColor3 = Value and "Accent" or "CheckboxBg" })
		Creator.OverrideTag(BoxStroke, { Color = Value and "Accent" or "CheckboxBorder" })
		TweenService:Create(Check, TweenFast, { ImageTransparency = Value and 0 or 1 }):Play()

		Library:SafeCallback(Toggle.Callback, Toggle.Value)
		Library:SafeCallback(Toggle.Changed, Toggle.Value)
	end

	function Toggle:Destroy()
		ToggleFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Creator.AddSignal(ToggleFrame.Frame.MouseButton1Click, function()
		Toggle:SetValue(not Toggle.Value)
	end)

	Toggle:SetValue(Toggle.Value)

	Library.Options[Idx] = Toggle
	return Toggle
end

return Element
