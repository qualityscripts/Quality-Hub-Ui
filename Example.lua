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

-- Sidebar categories (collapsible). Icons are Lucide names: https://lucide.dev/icons/
local Hub = Window:AddCategory("Quality Hub")
local Farm = Window:AddCategory("Farm")
local Progression = Window:AddCategory("Progression")
local Combat = Window:AddCategory("Combat")

local Tabs = {
    Home = Hub:AddTab({ Title = "Home", Icon = "home" }),
    AutoQuest = Farm:AddTab({ Title = "Auto Quest", Icon = "scroll" }),
    MobFarm = Farm:AddTab({ Title = "Mob Farm", Icon = "swords" }),
    Chests = Farm:AddTab({ Title = "Chests", Icon = "package" }),
    Haki = Progression:AddTab({ Title = "Haki", Icon = "flame" }),
    Hao = Progression:AddTab({ Title = "Hao", Icon = "crown" }),
    Combat = Combat:AddTab({ Title = "Combat", Icon = "sword" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

do
    -- Sections are cards. Side = "Left" / "Right" (alternates if omitted).
    local MobFarm = Tabs.MobFarm:AddSection({ Title = "Mob Farm", Icon = "swords", Side = "Left" })

    MobFarm:AddToggle("AutoFarmMobs", {
        Title = "Auto Farm Mobs",
        Description = "Kills the mobs you picked nonstop",
        Default = false,
    })

    local MobList = MobFarm:AddDropdown("Mobs", {
        Title = "Mobs",
        Description = "Which mobs to farm (none = all)",
        Values = { "Bandit", "Monkey", "Gorilla", "Pirate" },
        Multi = true,
        Default = {},
    })

    MobFarm:AddButton({
        Title = "Refresh Mobs",
        Description = "Updates the mob list",
        Callback = function()
            MobList:SetValues({ "Bandit", "Monkey", "Gorilla", "Pirate", "Brute" })
        end
    })

    MobFarm:AddToggle("QuestTargetsFirst", {
        Title = "Quest Targets First",
        Description = "Your own quest spawns go first",
        Default = true,
    })

    MobFarm:AddToggle("SkipOthersQuestMobs", {
        Title = "Skip Others' Quest Mobs",
        Description = "Leaves other players' quest spawns alone",
        Default = true,
    })

    local MobTP = Tabs.MobFarm:AddSection({ Title = "Mob TP", Icon = "map-pin", Side = "Left" })

    MobTP:AddDropdown("TPMob", {
        Title = "Mob",
        Description = "Which mob to go to",
        Values = { "Bandit", "Monkey", "Gorilla" },
        Multi = false,
    })

    MobTP:AddButton({
        Title = "Go To Mob",
        Description = "Takes you to the closest one",
        Callback = function()
            print("Go to", Options.TPMob.Value)
        end
    })

    local Position = Tabs.MobFarm:AddSection({ Title = "Farm Position", Icon = "crosshair", Side = "Right" })

    Position:AddDropdown("FarmMethod", {
        Title = "Farm Method",
        Description = "Teleport locks on, Tween glides over first",
        Values = { "Teleport", "Tween" },
        Default = "Teleport",
    })

    Position:AddDropdown("FarmPosition", {
        Title = "Position",
        Description = "Where you stand on the mob",
        Values = { "Behind", "Above", "Below", "Front" },
        Default = "Behind",
    })

    Position:AddSlider("Distance", {
        Title = "Distance",
        Description = "How far from the mob",
        Default = 3, Min = 0, Max = 20, Rounding = 1,
        Suffix = " studs",
    })

    Position:AddSlider("HeightOffset", {
        Title = "Height Offset",
        Description = "Moves you up or down",
        Default = 0, Min = -20, Max = 20, Rounding = 1,
    })

    Position:AddSlider("TweenSpeed", {
        Title = "Tween Speed",
        Description = "How fast Tween glides",
        Default = 100, Min = 16, Max = 500, Rounding = 0,
        Suffix = " studs/s",
    })

    local Welcome = Tabs.Home:AddSection({ Title = "Welcome", Icon = "home" })
    Welcome:AddParagraph({
        Title = "Quality Hub",
        Content = "Press LeftControl to hide or show the menu.",
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

Window:SelectTab(3) -- Mob Farm

SaveManager:LoadAutoloadConfig()
