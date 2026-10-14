local Root = script.Parent
local Themes = require(Root.Themes)
local Flipper = require(Root.Packages.Flipper)

local Creator = {
	Registry = {},
	Signals = {},
	TransparencyMotors = {},
	DefaultProperties = {
		ScreenGui = {
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		},
		Frame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ScrollingFrame = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ScrollBarImageColor3 = Color3.new(0, 0, 0),
		},
		TextLabel = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 1,
			TextSize = 14,
		},
		TextButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		TextBox = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			ClearTextOnFocus = false,
			Font = Enum.Font.SourceSans,
			Text = "",
			TextColor3 = Color3.new(0, 0, 0),
			TextSize = 14,
		},
		ImageLabel = {
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
		ImageButton = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			AutoButtonColor = false,
		},
		CanvasGroup = {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		},
	},
}

local function ApplyCustomProps(Object, Props)
	if Props.ThemeTag then
		Creator.AddThemeObject(Object, Props.ThemeTag)
	end
end

function Creator.AddSignal(Signal, Function)
	table.insert(Creator.Signals, Signal:Connect(Function))
end

function Creator.Disconnect()
	for Idx = #Creator.Signals, 1, -1 do
		local Connection = table.remove(Creator.Signals, Idx)
		Connection:Disconnect()
	end
end

function Creator.GetThemeProperty(Property)
	local Overrides = require(Root).ThemeOverrides
	if Overrides and Overrides[Property] ~= nil then
		return Overrides[Property]
	end
	if Themes[require(Root).Theme][Property] then
		return Themes[require(Root).Theme][Property]
	end
	return Themes["Quality"][Property]
end

local function ApplyTheme(Instance, Data)
	for Property, ColorIdx in next, Data.Properties do
		Instance[Property] = Creator.GetThemeProperty(ColorIdx)
	end
	if Data.Surface then
		local SurfaceTransparency = require(Root).UITransparency or 0
		Instance.BackgroundTransparency = Data.Properties.BackgroundColor3 == "Accent" and 0 or SurfaceTransparency
	end
end

-- Repaints every themed object; only needed when the theme, a color or the transparency changes.
function Creator.UpdateTheme()
	for Instance, Data in next, Creator.Registry do
		ApplyTheme(Instance, Data)
	end

	local ElementTransparency = Creator.GetThemeProperty("ElementTransparency")
	for Motor in next, Creator.TransparencyMotors do
		Motor:setGoal(Flipper.Instant.new(ElementTransparency))
	end
end

-- New objects are themed on their own: repainting everything per object made rebuilding a
-- dropdown's options repaint the whole UI once per option.
function Creator.AddThemeObject(Object, Properties)
	local Data = {
		Properties = Properties,
		-- Solid themed backgrounds follow the UI Transparency setting; ones that start hidden (hover/selection) manage their own.
		Surface = Properties.BackgroundColor3 ~= nil
			and Properties.BackgroundColor3 ~= "NotificationBg"
			and Object:IsA("GuiObject")
			and Object.BackgroundTransparency == 0,
	}

	if not Creator.Registry[Object] then
		-- Forget destroyed objects (e.g. old dropdown options) so repaints don't keep growing.
		Object.Destroying:Once(function()
			Creator.Registry[Object] = nil
		end)
	end
	Creator.Registry[Object] = Data
	ApplyTheme(Object, Data)
	return Object
end

function Creator.OverrideTag(Object, Properties)
	local Data = Creator.Registry[Object]
	Data.Properties = Properties
	ApplyTheme(Object, Data)
end

function Creator.New(Name, Properties, Children)
	local Object = Instance.new(Name)

	-- Default properties
	for Name, Value in next, Creator.DefaultProperties[Name] or {} do
		Object[Name] = Value
	end

	-- Properties
	for Name, Value in next, Properties or {} do
		if Name ~= "ThemeTag" then
			Object[Name] = Value
		end
	end

	-- Children
	for _, Child in next, Children or {} do
		Child.Parent = Object
	end

	ApplyCustomProps(Object, Properties)
	return Object
end

-- Soft halo drawn behind an element (must be a sibling with lower ZIndex, since children render above parents).
-- Built from stacked translucent rounded layers so it can take any color; fade it with GroupTransparency.
-- Size/Position should include Spread on every side; Corner is the corner radius of the glowing element.
function Creator.Glow(Spread, Corner, Props)
	local Layers = 10
	local Glow = Creator.New("CanvasGroup", {
		BackgroundTransparency = 1,
		ZIndex = 1,
	})
	for Index = 0, Layers - 1 do
		local Inset = Spread * Index / Layers
		Creator.New("Frame", {
			Size = UDim2.new(1, -Inset * 2, 1, -Inset * 2),
			Position = UDim2.fromOffset(Inset, Inset),
			BackgroundTransparency = 0.93,
			Parent = Glow,
			ThemeTag = { BackgroundColor3 = "Glow" },
		}, {
			Creator.New("UICorner", { CornerRadius = UDim.new(0, Corner + Spread - Inset) }),
		})
	end
	for Name, Value in next, Props or {} do
		Glow[Name] = Value
	end
	return Glow
end

function Creator.SpringMotor(Initial, Instance, Prop, IgnoreDialogCheck, ResetOnThemeChange)
	IgnoreDialogCheck = IgnoreDialogCheck or false
	ResetOnThemeChange = ResetOnThemeChange or false
	local Motor = Flipper.SingleMotor.new(Initial)
	Motor:onStep(function(value)
		Instance[Prop] = value
	end)

	if ResetOnThemeChange then
		Creator.TransparencyMotors[Motor] = true
		Motor:setGoal(Flipper.Instant.new(Creator.GetThemeProperty("ElementTransparency")))
		Instance.Destroying:Once(function()
			Creator.TransparencyMotors[Motor] = nil
			Motor:stop()
		end)
	end

	local function SetValue(Value, Ignore)
		Ignore = Ignore or false
		if not IgnoreDialogCheck then
			if not Ignore then
				if Prop == "BackgroundTransparency" and require(Root).DialogOpen then
					return
				end
			end
		end
		Motor:setGoal(Flipper.Spring.new(Value, { frequency = 8 }))
	end

	return Motor, SetValue
end

return Creator
