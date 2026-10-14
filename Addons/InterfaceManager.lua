local httpService = game:GetService("HttpService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentSettings"
    InterfaceManager.Settings = {
        Theme = "Quality",
        Acrylic = false,
        Transparency = false,
        MenuKeybind = "LeftControl"
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
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})

        InterfaceTheme:SetValue(Settings.Theme)
	
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
	
		section:AddToggle("TransparentToggle", {
			Title = "Transparency",
			Description = "Makes the interface transparent.",
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})
	
		local MenuKeybind = section:AddKeybind("MenuKeybind", { Title = "Minimize Bind", Default = Settings.MenuKeybind })
		MenuKeybind:OnChanged(function()
			Settings.MenuKeybind = MenuKeybind.Value
            InterfaceManager:SaveSettings()
		end)
		Library.MinimizeKeybind = MenuKeybind

		InterfaceManager:BuildCustomizeSection(tab)
    end

	InterfaceManager.ColorOptions = {
		{ Key = "Accent", Title = "Accent Color", Description = "Checkboxes, slider fill and the tab indicator." },
		{ Key = "Glow", Title = "Glow Color", Description = "The glow around sliders and checkboxes." },
		{ Key = "Background", Title = "Background Color", Description = "Main window background." },
		{ Key = "SectionBg", Title = "Section Color", Description = "Background of the section cards." },
		{ Key = "ControlBg", Title = "Button Color", Description = "Buttons, dropdowns and inputs." },
		{ Key = "ControlBorder", Title = "Button Border Color", Description = "Outline of buttons and dropdowns." },
		{ Key = "TabSelected", Title = "Selected Tab Color", Description = "Highlight behind the active tab." },
		{ Key = "Text", Title = "Text Color", Description = "Titles and labels." },
		{ Key = "SubText", Title = "Description Color", Description = "Grey description text." },
	}

	function InterfaceManager:ApplySavedColors()
		local Library = self.Library
		for Key, Hex in next, InterfaceManager.Settings.Colors or {} do
			local Ok, Color = pcall(Color3.fromHex, Hex)
			if Ok then
				Library:SetThemeColor(Key, Color)
			end
		end
	end

	function InterfaceManager:BuildCustomizeSection(tab)
		local Library = self.Library
		local Settings = InterfaceManager.Settings
		Settings.Colors = Settings.Colors or {}

		InterfaceManager:ApplySavedColors()

		local section = tab:AddSection({ Title = "Customize", Icon = "palette" })
		local Pickers = {}
		local Ready = false

		for _, Option in ipairs(InterfaceManager.ColorOptions) do
			Pickers[Option.Key] = section:AddColorpicker("Color_" .. Option.Key, {
				Title = Option.Title,
				Description = Option.Description,
				Default = Library:GetThemeColor(Option.Key),
				Callback = function(Color)
					if not Ready then
						return
					end
					Library:SetThemeColor(Option.Key, Color)
					Settings.Colors[Option.Key] = Color:ToHex()
					InterfaceManager:SaveSettings()
				end,
			})
		end

		section:AddButton({
			Title = "Reset Colors",
			Description = "Puts every color back to the theme default.",
			Callback = function()
				Ready = false
				Library:ResetThemeColors()
				Settings.Colors = {}
				InterfaceManager:SaveSettings()
				for Key, Picker in next, Pickers do
					Picker:SetValueRGB(Library:GetThemeColor(Key))
				end
				Ready = true
			end,
		})

		Ready = true
	end
end

return InterfaceManager