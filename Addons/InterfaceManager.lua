local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Acrylic = false,
        MenuKeybind = "LeftControl",
        UIScale = 100
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end

		table.insert(paths, self.Folder)
		table.insert(paths, self.Folder .. "/settings")

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:SaveSettings()
        writefile(self.Folder .. "/options.json", httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = self.Folder .. "/options.json"
        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
        -- Theme and colors are only kept through saved themes, never auto-saved; drop values older versions wrote.
        InterfaceManager.Settings.Theme = nil
        InterfaceManager.Settings.Colors = nil
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")
		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local section = tab:AddSection("Interface")

		local InterfaceTheme = section:AddDropdown("InterfaceTheme", {
			Title = "Theme",
			Description = "Changes the interface theme.",
			Values = Library.Themes,
			Default = Library.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
			end
		})
		InterfaceManager.ThemeDropdown = InterfaceTheme
	
		if Library.UseAcrylic then
			section:AddToggle("AcrylicToggle", {
				Title = "Acrylic",
				Description = "The blurred background requires graphic quality 8+",
				Default = Settings.Acrylic,
				Callback = function(Value)
					Library:ToggleAcrylic(Value)
                    Settings.Acrylic = Value
                    InterfaceManager:SaveSettings()
				end
			})
		end
	
		section:AddSlider("InterfaceTransparency", {
			Title = "Ui Transparency",
			Description = "Makes the whole interface see-through.",
			Default = Settings.UITransparency or 50,
			Min = 0,
			Max = 90,
			Rounding = 0,
			Suffix = "%",
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.UITransparency = Value
				InterfaceManager:SaveSettings()
			end
		})
	
		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind

		section:AddSlider("InterfaceUIScale", {
			Title = "UI Scale",
			Description = "Makes the whole interface smaller or bigger.",
			Default = Settings.UIScale or 100,
			Min = 10,
			Max = 100,
			Rounding = 0,
			Suffix = "%",
			Callback = function(Value)
				Library.Window:SetScale(Value)
				Settings.UIScale = Value
				InterfaceManager:SaveSettings()
			end,
		})

		InterfaceManager:BuildCustomizeSection(tab)
    end

	InterfaceManager.ColorOptions = {
		{ Key = "Accent", Title = "Accent Color", Description = "Checkboxes, slider fill and the tab indicator." },
		{ Key = "Glow", Title = "Glow Color", Description = "The glow around sliders and checkboxes." },
		{ Key = "Background", Title = "Background Color", Description = "Main window background." },
		{ Key = "UIOutline", Title = "Ui Outline Color", Description = "Outline around the whole window." },
		{ Key = "SectionBg", Title = "Section Color", Description = "Background of the section cards." },
		{ Key = "ControlBg", Title = "Button Color", Description = "Buttons, dropdowns and inputs." },
		{ Key = "ControlBorder", Title = "Button Border Color", Description = "Outline of buttons and dropdowns." },
		{ Key = "TabSelected", Title = "Selected Tab Color", Description = "Highlight behind the active tab." },
		{ Key = "Text", Title = "Text Color", Description = "Titles and labels." },
		{ Key = "SubText", Title = "Description Color", Description = "Grey description text." },
		{ Key = "NotificationBg", Title = "Notification Color", Description = "Background of notifications." },
	}

	function InterfaceManager:BuildCustomizeSection(tab)
		local Library = self.Library

		local section = tab:AddSection({ Title = "Customize", Icon = "palette" })
		local Pickers = {}
		InterfaceManager.Pickers = Pickers
		InterfaceManager.ColorsReady = false

		for _, Option in ipairs(InterfaceManager.ColorOptions) do
			Pickers[Option.Key] = section:AddColorpicker("Color_" .. Option.Key, {
				Title = Option.Title,
				Description = Option.Description,
				Default = Library:GetThemeColor(Option.Key),
				Callback = function(Color)
					if not InterfaceManager.ColorsReady then
						return
					end
					Library:SetThemeColor(Option.Key, Color)
				end,
			})
		end

		section:AddButton({
			Title = "Reset Colors",
			Description = "Puts every color back to the theme default.",
			Callback = function()
				InterfaceManager:ApplyColors({})
			end,
		})

		InterfaceManager.ColorsReady = true

		InterfaceManager:BuildThemeListSection(tab)
	end

	-- Replaces all custom colors with the given { Key = hex } map and updates the pickers (nothing is written to disk).
	function InterfaceManager:ApplyColors(Colors)
		local Library = self.Library
		InterfaceManager.ColorsReady = false
		Library:ResetThemeColors()
		for Key, Hex in next, Colors do
			local Ok, Color = pcall(Color3.fromHex, Hex)
			if Ok then
				Library:SetThemeColor(Key, Color)
			end
		end
		for Key, Picker in next, InterfaceManager.Pickers or {} do
			Picker:SetValueRGB(Library:GetThemeColor(Key))
		end
		InterfaceManager.ColorsReady = true
	end

	function InterfaceManager:ThemesFolder()
		local Path = self.Folder .. "/themes"
		if not isfolder(self.Folder) then
			makefolder(self.Folder)
		end
		if not isfolder(Path) then
			makefolder(Path)
		end
		return Path
	end

	function InterfaceManager:SaveTheme(Name)
		local Library = self.Library
		local Colors = {}
		for _, Option in ipairs(InterfaceManager.ColorOptions) do
			Colors[Option.Key] = Library:GetThemeColor(Option.Key):ToHex()
		end
		local Ok, Err = pcall(writefile, self:ThemesFolder() .. "/" .. Name .. ".json", httpService:JSONEncode({ Theme = Library.Theme, Colors = Colors }))
		return Ok, Err
	end

	function InterfaceManager:LoadTheme(Name)
		local Path = self:ThemesFolder() .. "/" .. tostring(Name) .. ".json"
		if not Name or not isfile(Path) then
			return false, "theme not found"
		end
		local Ok, Data = pcall(httpService.JSONDecode, httpService, readfile(Path))
		if not Ok or type(Data) ~= "table" or type(Data.Colors) ~= "table" then
			return false, "invalid theme file"
		end
		if type(Data.Theme) == "string" and table.find(self.Library.Themes, Data.Theme) and InterfaceManager.ThemeDropdown then
			InterfaceManager.ThemeDropdown:SetValue(Data.Theme)
		end
		InterfaceManager:ApplyColors(Data.Colors)
		return true
	end

	function InterfaceManager:RefreshThemeList()
		local Out = {}
		for _, File in ipairs(listfiles(self:ThemesFolder())) do
			local Name = File:match("([^/\\]+)%.json$")
			if Name then
				table.insert(Out, Name)
			end
		end
		return Out
	end

	function InterfaceManager:BuildThemeListSection(tab)
		local Library = self.Library
		local Options = Library.Options

		local function Notify(Text)
			Library:Notify({ Title = "Interface", Content = "Themes", SubContent = Text, Duration = 6 })
		end

		local section = tab:AddSection({ Title = "Saved Themes", Icon = "palette" })

		section:AddInput("InterfaceManager_ThemeName", { Title = "Theme name", Placeholder = "My theme" })
		section:AddDropdown("InterfaceManager_ThemeList", {
			Title = "Theme list",
			Values = self:RefreshThemeList(),
			AllowNull = true,
		})

		local function RefreshList()
			Options.InterfaceManager_ThemeList:SetValues(self:RefreshThemeList())
			Options.InterfaceManager_ThemeList:SetValue(nil)
		end

		section:AddButton({
			Title = "Create theme",
			Description = "Saves your current colors as a new theme.",
			Callback = function()
				local Name = Options.InterfaceManager_ThemeName.Value
				if Name:gsub(" ", "") == "" then
					return Notify("Invalid theme name (empty)")
				end
				if Name:find("[/\\]") then
					return Notify("Theme name can't contain slashes")
				end
				local Ok, Err = self:SaveTheme(Name)
				if not Ok then
					return Notify("Failed to save theme: " .. tostring(Err))
				end
				Notify(string.format("Created theme %q", Name))
				RefreshList()
			end,
		})

		section:AddButton({
			Title = "Load theme",
			Callback = function()
				local Name = Options.InterfaceManager_ThemeList.Value
				local Ok, Err = self:LoadTheme(Name)
				if not Ok then
					return Notify("Failed to load theme: " .. tostring(Err))
				end
				Notify(string.format("Loaded theme %q", Name))
			end,
		})

		section:AddButton({
			Title = "Overwrite theme",
			Callback = function()
				local Name = Options.InterfaceManager_ThemeList.Value
				if not Name then
					return Notify("Pick a theme from the list first")
				end
				local Ok, Err = self:SaveTheme(Name)
				if not Ok then
					return Notify("Failed to overwrite theme: " .. tostring(Err))
				end
				Notify(string.format("Overwrote theme %q", Name))
			end,
		})

		section:AddButton({
			Title = "Delete theme",
			Callback = function()
				local Name = Options.InterfaceManager_ThemeList.Value
				local Path = self:ThemesFolder() .. "/" .. tostring(Name) .. ".json"
				if not Name or not isfile(Path) then
					return Notify("Pick a theme from the list first")
				end
				delfile(Path)
				Notify(string.format("Deleted theme %q", Name))
				RefreshList()
			end,
		})

		section:AddButton({ Title = "Refresh list", Callback = RefreshList })
	end
end

return InterfaceManager