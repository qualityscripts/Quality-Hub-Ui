local Fluent = loadstring(game:HttpGet("https://github.com/qualityscripts/Quality-Hub-Ui/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualityscripts/Quality-Hub-Ui/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/qualityscripts/Quality-Hub-Ui/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Quality Hub",
    SubTitle = "v1.0",
    TabWidth = 220,
    Size = UDim2.fromOffset(880, 600),
    HideName = true, -- masks your username in the sidebar profile
    Image = "", -- open/close button image: asset id ("rbxassetid://123" or "123"); empty shows the hub initials
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs can also be grouped with Window:AddCategory("Name"):AddTab({...}). Icons are Lucide names: https://lucide.dev/icons/
local Tabs = {
    Example = Window:AddTab({ Title = "Example", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

do
    -- Sections are cards. Side = "Left" / "Right" (alternates if omitted).
    local Example = Tabs.Example:AddSection({ Title = "Example", Icon = "home", Side = "Left" })

    Example:AddParagraph({
        Title = "Example",
        Content = "Example paragraph.",
    })

    Example:AddButton({
        Title = "Example",
        Description = "Example button",
        Callback = function()
            print("Example button pressed")
        end
    })

    Example:AddToggle("ExampleToggle", {
        Title = "Example",
        Description = "Example toggle",
        Default = false,
        Callback = function(Value)
            print("Example toggle:", Value)
        end
    })

    Example:AddSlider("ExampleSlider", {
        Title = "Example",
        Description = "Example slider",
        Default = 50, Min = 0, Max = 100, Rounding = 0,
        Suffix = "%", -- optional text after the value
        Callback = function(Value)
            print("Example slider:", Value)
        end
    })

    Example:AddDropdown("ExampleDropdown", {
        Title = "Example",
        Description = "Example dropdown",
        Values = { "Example 1", "Example 2", "Example 3" },
        Multi = false, -- true lets you pick several values
        Default = "Example 1",
        Callback = function(Value)
            print("Example dropdown:", Value)
        end
    })

    Example:AddColorpicker("ExampleColorpicker", {
        Title = "Example",
        Description = "Example color picker",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Color)
            print("Example color:", Color)
        end
    })

    Example:AddKeybind("ExampleKeybind", {
        Title = "Example",
        Description = "Example keybind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "E",
        Callback = function(Value)
            print("Example keybind:", Value)
        end
    })

    Example:AddInput("ExampleInput", {
        Title = "Example",
        Description = "Example input",
        Default = "",
        Placeholder = "Example",
        Numeric = false, -- only allows numbers
        Finished = false, -- only calls back when you press enter
        Callback = function(Value)
            print("Example input:", Value)
        end
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("QualityHub")
SaveManager:SetFolder("QualityHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
