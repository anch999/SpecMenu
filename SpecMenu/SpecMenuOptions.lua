local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

local favoriteNum = ""
local lastSpecPos

--Borrowed from Atlas, thanks Dan!
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function SPM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu")
	end
end

function SPM:Options_Menu_OnClick()
	local thisID = this:GetID()

	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, thisID)
	if SPM.db.Specs[thisID][1] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, lastSpecPos)
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, SPM.db.Specs[thisID][1])
	end

	if SPM.db.Specs[thisID][2] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, lastSpecPos)
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, SPM.db.Specs[thisID][2])
	end

	SPM.optionsSpecNum = thisID
end

local function SpecMenu_Options_Menu_Initialize()
    local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
			text = SPM:GetSpecInfo(i),
			func = SPM.Options_Menu_OnClick,
		}
			UIDropDownMenu_AddButton(info)
	end
end

function SPM:Options_FavoriteLastSpec_OnClick()
	local thisID = this:GetID()
	if favoriteNum == "1" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, thisID)
		SPM.db.Specs[SPM.optionsSpecNum][1] = "LastSpec"
	elseif favoriteNum == "2" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, thisID)
		SPM.db.Specs[SPM.optionsSpecNum][2] = "LastSpec"
	end
end

function SPM:Options_Favorite1_OnClick()
	local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, thisID)
	SPM.db.Specs[SPM.optionsSpecNum][1] = thisID
end

local function SpecMenu_Options_Favorite1_Initialize()
	--Loads the spec list into the self.options.favorite1 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
					text = SPM:GetSpecInfo(i),
					func = SPM.Options_Favorite1_OnClick,
				}
					UIDropDownMenu_AddButton(info)
					lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the self.options.favorite1 dropdown menu 
	info = {
		text = "Last Active Spec",
		func = SPM.Options_FavoriteLastSpec_OnClick,
	}
		UIDropDownMenu_AddButton(info)
		favoriteNum = "1"
end

function SPM:Options_Favorite2_OnClick()
	local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, thisID)
	SPM.db.Specs[SPM.optionsSpecNum][2] = thisID
end

local function SpecMenu_Options_Favorite2_Initialize()
	--Loads the spec list into the self.options.favorite2 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
			text = SPM:GetSpecInfo(i),
			func = SPM.Options_Favorite2_OnClick,
		}
			UIDropDownMenu_AddButton(info)
			lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the self.options.favorite2 dropdown menu 
	info = {
		text = "Last Active Spec",
		func = SPM.Options_FavoriteLastSpec_OnClick,
	}
		UIDropDownMenu_AddButton(info)
		favoriteNum = "2"

end

function SPM:Options_UpateDB_OnClick()
		--Updates the name of the Spec selected
		if not CA_IsSpellKnown(SPM.SpecInfo[1]) then return end
		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM:GetSpecInfo(SPM.optionsSpecNum))
end

function SpecMenu_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	if CA_IsSpellKnown(SPM.SpecInfo[1]) then
			local menuID = SPM:GetSpecId()
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, menuID)
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, SPM.db.Specs[menuID][1])
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, SPM.db.Specs[menuID][2])

		if SPM.db.Specs[menuID][1] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_favorite1, "Last Active Spec")
		else
			UIDropDownMenu_SetText(SpecMenuOptions_favorite1, SPM:GetSpecInfo(SPM.db.Specs[menuID][1]))
		end

		if SPM.db.Specs[menuID][2] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_favorite2, "Last Active Spec")
		else
			UIDropDownMenu_SetText(SpecMenuOptions_favorite2, SPM:GetSpecInfo(SPM.db.Specs[menuID][2]))
		end
		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM:GetSpecInfo(menuID))
		SPM.optionsSpecNum = menuID
	end
end

function SPM:CreateOptionsUI()
--Creates the options frame and all its assets
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
		self.options ={ panel = CreateFrame("FRAME", "SpecMenuOptionsFrame", UIParent, nil) }
    	self.options.fstring = self.options.panel:CreateFontString(self.options, "OVERLAY", "GameFontNormal")
		self.options.fstring:SetText("Spec Menu Settings")
		self.options.fstring:SetPoint("TOPLEFT", 15, -15)
		self.options.panel.name = "SpecMenu"
		InterfaceOptions_AddCategory(self.options.panel)

	self.options.specmenu = CreateFrame("Button", "SpecMenuOptions_Menu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    self.options.specmenu:SetPoint("TOPLEFT", 15, -60)
	self.options.specmenu.Lable = self.options.specmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.specmenu.Lable:SetJustifyH("LEFT")
	self.options.specmenu.Lable:SetPoint("LEFT", self.options.specmenu, 190, 0)
	self.options.specmenu.Lable:SetText("Select Specialization")
	self.options.specmenu:SetScript("OnClick", self.Options_UpateDB_OnClick)

	self.options.favorite1 = CreateFrame("Button", "SpecMenuOptions_favorite1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    self.options.favorite1:SetPoint("TOPLEFT", 15, -95)
	self.options.favorite1.Lable = self.options.favorite1:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.favorite1.Lable:SetJustifyH("LEFT")
	self.options.favorite1.Lable:SetPoint("LEFT", self.options.favorite1, 190, 0)
	self.options.favorite1.Lable:SetText("Favorite Left Click")

	self.options.favorite2 = CreateFrame("Button", "SpecMenuOptions_favorite2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    self.options.favorite2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -130)
	self.options.favorite2.Lable = self.options.favorite2:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.favorite2.Lable:SetJustifyH("LEFT")
	self.options.favorite2.Lable:SetPoint("LEFT", self.options.favorite2, 190, 0)
	self.options.favorite2.Lable:SetText("Favorite Right Click")

	self.options.hideMenu = CreateFrame("CheckButton", "SpecMenuOptions_HideMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMenu:SetPoint("TOPLEFT", 15, -200)
	self.options.hideMenu.Lable = self.options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMenu.Lable:SetJustifyH("LEFT")
	self.options.hideMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMenu.Lable:SetText("Hide Main Menu")
	self.options.hideMenu:SetScript("OnClick", function() 
		if self.db.HideMenu then
			SpecMenuFrame:Show()
			self.db.HideMenu = false
		else
			SpecMenuFrame:Hide()
			self.db.HideMenu = true
		end
	end)

	self.options.showOnMouseOver = CreateFrame("CheckButton", "SpecMenuOptions_ShowOnMouseOver", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.showOnMouseOver:SetPoint("TOPLEFT", 15, -235)
	self.options.showOnMouseOver.Lable = self.options.showOnMouseOver:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.showOnMouseOver.Lable:SetJustifyH("LEFT")
	self.options.showOnMouseOver.Lable:SetPoint("LEFT", 30, 0)
	self.options.showOnMouseOver.Lable:SetText("Only show menu button on mouse over")
	self.options.showOnMouseOver:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Only shows the main menu button on mouse over")
        GameTooltip:Show()
    end)
    self.options.showOnMouseOver:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.options.showOnMouseOver:SetScript("OnClick", function()
		if self.db.ShowMenuOnHover then
			SpecMenuFrame_Menu:Show()
            SpecMenuFrame_Favorite:Show()
            SpecMenuFrame.icon:Show()
			SpecMenuFrame.Text:Show()
			self.db.ShowMenuOnHover = false
		else
			SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_Favorite:Hide()
            SpecMenuFrame.icon:Hide()
			SpecMenuFrame.Text:Hide()
			self.db.ShowMenuOnHover = true
		end

	end)

	self.options.autoMenu = CreateFrame("CheckButton", "SpecMenuOptions_AutoMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoMenu:SetPoint("TOPLEFT", 15, -270)
	self.options.autoMenu.Lable = self.options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoMenu.Lable:SetJustifyH("LEFT")
	self.options.autoMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoMenu.Lable:SetText("Auto open menu of mouse over")
	self.options.autoMenu:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Auto opens the menu when you mouse over the button. \nHolding alt will open the enchant specs menu")
        GameTooltip:Show()
    end)
    self.options.autoMenu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	self.options.autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	self.options.hideMinimap = CreateFrame("CheckButton", "SpecMenuOptions_HideMinimap", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 15, -305)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide Minimap Icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.hideSpecDisplay = CreateFrame("CheckButton", "SpecMenuOptions_HideSpecDisplay", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideSpecDisplay:SetPoint("TOPLEFT", 380, -55)
	self.options.hideSpecDisplay.Lable = self.options.hideSpecDisplay:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideSpecDisplay.Lable:SetJustifyH("LEFT")
	self.options.hideSpecDisplay.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideSpecDisplay.Lable:SetText("Hide Spec/Enchant Display")
	self.options.hideSpecDisplay:SetScript("OnClick", function()
		self.db.hideSpecDisplay = not self.db.hideSpecDisplay
		self:CreateSpecDisplay()
		if self.db.hideSpecDisplay then
			SpecDisplayFrame:Hide()
		else
			SpecDisplayFrame:Show()
			SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
		end
	end)

	self.options.hideSpecDisplayBackground = CreateFrame("CheckButton", "SpecMenuOptions_HideSpecDisplayBackground", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideSpecDisplayBackground:SetPoint("TOPLEFT", 380, -90)
	self.options.hideSpecDisplayBackground.Lable = self.options.hideSpecDisplayBackground:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideSpecDisplayBackground.Lable:SetJustifyH("LEFT")
	self.options.hideSpecDisplayBackground.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideSpecDisplayBackground.Lable:SetText("Hide Spec/Enchant Display Background")
	self.options.hideSpecDisplayBackground:SetScript("OnClick", function()
		self.db.hideSpecDisplayBackground = not self.db.hideSpecDisplayBackground
		if self.db.hideSpecDisplayBackground then
			SpecDisplayFrame:SetBackdropColor(0, 0, 0, 0)
			SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 0)
		else
			SpecDisplayFrame:SetBackdropColor(0, 0, 0, 5)
			SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 5)
		end
	end)

	self.options.displayScale = CreateFrame("Slider", "SpecMenuOptionsDisplayScale", SpecMenuOptionsFrame,"OptionsSliderTemplate")
	self.options.displayScale:SetSize(240,16)
	self.options.displayScale:SetPoint("TOPLEFT", 380,-140)
	self.options.displayScale:SetMinMaxValues(0.25, 1.5)
	_G[self.options.displayScale:GetName().."Text"]:SetText("Spec Display Scale: ".." ("..round(self.options.displayScale:GetValue(),2)..")")
	_G[self.options.displayScale:GetName().."Low"]:SetText(0.25)
	_G[self.options.displayScale:GetName().."High"]:SetText(1.5)
	self.options.displayScale:SetValueStep(0.01)
	self.options.displayScale:SetScript("OnShow", function() self.options.displayScale:SetValue(self.db.SpecDisplayScale) end)
    self.options.displayScale:SetScript("OnValueChanged", function()
		_G[self.options.displayScale:GetName().."Text"]:SetText("Spec Display Scale: ".." ("..round(self.options.displayScale:GetValue(),2)..")")
        self.db.SpecDisplayScale = self.options.displayScale:GetValue()
		if SpecDisplayFrame then
        	SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
			self:SetDisplayText()
		end
    end)

	self.options.buttonScale = CreateFrame("Slider", "SpecMenuOptionsButtonScale", SpecMenuOptionsFrame,"OptionsSliderTemplate")
	self.options.buttonScale:SetSize(240,16)
	self.options.buttonScale:SetPoint("TOPLEFT", 380,-190)
	self.options.buttonScale:SetMinMaxValues(0.25, 1.5)
	_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
	_G[self.options.buttonScale:GetName().."Low"]:SetText(0.25)
	_G[self.options.buttonScale:GetName().."High"]:SetText(1.5)
	self.options.buttonScale:SetValueStep(0.01)
	self.options.buttonScale:SetScript("OnShow", function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end)
    self.options.buttonScale:SetScript("OnValueChanged", function()
		_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
        self.db.buttonScale = self.options.buttonScale:GetValue()
		if self.standaloneFrame then
        	self.standaloneFrame:SetScale(self.db.buttonScale)
		end
    end)

	self.options.txtSize = CreateFrame("Button", "SpecMenuOptions_TxtSizeMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -340)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu Text Size")
end

	SPM:CreateOptionsUI()

	local function SpecMenu_Txt_Menu_Initialize()
		local info
			for i = 10, 25 do
						info = {
							text = i;
							func = function() 
								SPM.db.txtSize = i 
								local thisID = this:GetID();
								UIDropDownMenu_SetSelectedID(SpecMenuOptions_TxtSizeMenu, thisID)
							end;
						};
							UIDropDownMenu_AddButton(info);
			end
		end

	function SPM:OptionsDropDownInitialize()
		--Setup for Dropdown menus in the settings
		UIDropDownMenu_Initialize(SpecMenuOptions_Menu, SpecMenu_Options_Menu_Initialize)
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu)
		UIDropDownMenu_SetWidth(SpecMenuOptions_Menu, 150)

		UIDropDownMenu_Initialize(SpecMenuOptions_favorite1, SpecMenu_Options_Favorite1_Initialize)
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1)
		UIDropDownMenu_SetWidth(SpecMenuOptions_favorite1, 150)

		UIDropDownMenu_Initialize(SpecMenuOptions_favorite2, SpecMenu_Options_Favorite2_Initialize)
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2)
		UIDropDownMenu_SetWidth(SpecMenuOptions_favorite2, 150)

		UIDropDownMenu_Initialize(SpecMenuOptions_TxtSizeMenu, SpecMenu_Txt_Menu_Initialize)
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_TxtSizeMenu)
		UIDropDownMenu_SetText(SpecMenuOptions_TxtSizeMenu, SPM.db.txtSize)
		UIDropDownMenu_SetWidth(SpecMenuOptions_TxtSizeMenu, 150)
	end