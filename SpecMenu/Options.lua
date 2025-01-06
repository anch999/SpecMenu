local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")
local WHITE = "|cffFFFFFF"

function SPM:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu")
	end
end

--Creates the options frame and all its assets
function SPM:CreateOptionsUI()
	local Options = {
		AddonName = "SpecMenu",
		TitleText = "SpecMenu Settings",
		{
		Name = "SpecMenu",
		Left = {
			{
				Type = "Menu",
				Name = "specmenu",
				Lable = "Select Specialization",
				Func = 	function(name, specID)
					self.optionsSpecNum = specID
					self:UpdateDropDownMenus("SpecMenu")
				end,
				Menu = function()
					local selections = {}
					for i, _ in pairs(self.db.Specs) do
						local name = self:GetSpecInfo(i)
						tinsert(selections, name)
					end
					return selections, self:GetSpecInfo(self.optionsSpecNum) or "Last Active Spec"
				end
			},
			{
				Type = "Menu",
				Name = "favorite1",
				Lable = "Favorite Left Click",
				Func = 	function(name, specID)
					self.db.Specs[self.optionsSpecNum][1] = name == "Last Active Spec" and name or specID
				end,
				Menu = function()
					local selections = {}
					for i, _ in pairs(self.db.Specs) do
						local name = self:GetSpecInfo(i)
						tinsert(selections, name)
					end
					tinsert(selections, "Last Active Spec")
					return selections, self.db.Specs[self.optionsSpecNum][1] == "Last Active Spec" and "Last Active Spec" or self:GetSpecInfo(self.db.Specs[self.optionsSpecNum][1])
				end
			},
			{
				Type = "Menu",
				Name = "favorite2",
				Lable = "Favorite Right Click",
				Func = 	function(name, specID)
					self.db.Specs[self.optionsSpecNum][2] = name == "Last Active Spec" and name or specID
				end,
				Menu = function()
					local selections = {}
					for i, _ in pairs(self.db.Specs) do
						local name = self:GetSpecInfo(i)
						tinsert(selections, name)
					end
					tinsert(selections, "Last Active Spec")
					return selections, self.db.Specs[self.optionsSpecNum][2] == "Last Active Spec" and "Last Active Spec" or self:GetSpecInfo(self.db.Specs[self.optionsSpecNum][2])
				end
			},
			{
				Type = "CheckButton",
				Name = "HideMenu",
				Lable = "Hide Standalone Button",
				OnClick = 	function()
					if self.db.HideMenu then
						self.standaloneButton:Show()
						self.db.HideMenu = false
					else
						self.standaloneButton:Hide()
						self.db.HideMenu = true
					end
				end
			},
			{
				Type = "CheckButton",
				Name = "ShowMenuOnHover",
				Lable = "Only Show Standalone Button on Hover",
				OnClick = function()
					self.db.ShowMenuOnHover = not self.db.ShowMenuOnHover
					self:SetFrameAlpha()
				end
			},
			{
				Type = "CheckButton",
				Name = "autoMenu",
				Lable = "Open menu on mouse over",
				OnClick = function() self.db.autoMenu = not self.db.autoMenu end
			},
			{
				Type = "CheckButton",
				Name = "hideSpecDisplay",
				Lable = "Hide Spec/Enchant Display",
				OnClick = function() 
					self.db.hideSpecDisplay = not self.db.hideSpecDisplay
					self:CreateSpecDisplay()
					if self.db.hideSpecDisplay then
						SpecDisplayFrame:Hide()
					else
						SpecDisplayFrame:Show()
						SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
					end
				end
			},
			{
				Type = "CheckButton",
				Name = "hideSpecDisplayBackground",
				Lable = "Hide Spec/Enchant Display Background",
				OnClick = function()
					self.db.hideSpecDisplayBackground = not self.db.hideSpecDisplayBackground
					if self.db.hideSpecDisplayBackground then
						SpecDisplayFrame:SetBackdropColor(0, 0, 0, 0)
						SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 0)
					else
						SpecDisplayFrame:SetBackdropColor(0, 0, 0, 5)
						SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 5)
					end
				end
			},
		},
		Right = {
			{
				Type = "CheckButton",
				Name = "minimap",
				Lable = "Hide minimap icon",
				OnClick = function()
					self:ToggleMinimap()
				end
			},
			{
				Type = "Menu",
				Name = "txtSize",
				Lable = "Menu text size",
				Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
			},
			{
				Type = "Slider",
				Name = "buttonScale",
				Lable = "Standalone Button Scale",
				MinMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end,
				OnValueChanged = function()
					self.db.buttonScale = self.options.buttonScale:GetValue()
					if self.standaloneButton then
						self.standaloneButton:SetScale(self.db.buttonScale)
					end
				end
			};
			{
				Type = "Slider",
				Name = "displayScale",
				Lable = "Spec/Enchant Display Scale",
				MinMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.displayScale:SetValue(self.db.SpecDisplayScale or 1) end,
				OnValueChanged = function()
					self.db.SpecDisplayScale = self.options.displayScale:GetValue()
					if SpecDisplayFrame then
						SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
					end
				end
			};
		}
		}
	}

	self.options = self:CreateOptionsPages(Options, SpecMenuDB)
end