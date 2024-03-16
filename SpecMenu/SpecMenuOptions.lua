local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")
local specmenu_options_swap = "Last Active Spec"
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
		SpecMenu_favoriteNum2 = "LastSpec"
		SPM.db.Specs[SPM.optionsSpecNum][2] = "LastSpec"
	end
end

function SPM:Options_Favorite1_OnClick()
	local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, thisID)
	SPM.db.Specs[SPM.optionsSpecNum][1] = thisID
end

local function SpecMenu_Options_Favorite1_Initialize()
	--Loads the spec list into the favorite1 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
					text = SPM:GetSpecInfo(i),
					func = SPM.Options_Favorite1_OnClick,
				}
					UIDropDownMenu_AddButton(info)
					lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the favorite1 dropdown menu 
	info = {
		text = specmenu_options_swap,
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
	--Loads the spec list into the favorite2 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
			text = SPM:GetSpecInfo(i),
			func = SPM.Options_Favorite2_OnClick,
		}
			UIDropDownMenu_AddButton(info)
			lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the favorite2 dropdown menu 
	info = {
		text = specmenu_options_swap,
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
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, SPM.db.Specs[menuID][2])

		if SPM.db.Specs[menuID][1] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_favorite1, specmenu_options_swap)
		else
			UIDropDownMenu_SetText(SpecMenuOptions_favorite1, SPM:GetSpecInfo(SPM.db.Specs[menuID][1]))
		end

		if SPM.db.Specs[menuID][2] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_favorite2, specmenu_options_swap)
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
	local mainframe = {}
		mainframe.panel = CreateFrame("FRAME", "SpecMenuOptionsFrame", UIParent, nil)
    	local fstring = mainframe.panel:CreateFontString(mainframe, "OVERLAY", "GameFontNormal")
		fstring:SetText("Spec Menu Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		mainframe.panel.name = "SpecMenu"
		InterfaceOptions_AddCategory(mainframe.panel)

	local specmenu = CreateFrame("Button", "SpecMenuOptions_Menu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    specmenu:SetPoint("TOPLEFT", 15, -60)
	specmenu.Lable = specmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	specmenu.Lable:SetJustifyH("LEFT")
	specmenu.Lable:SetPoint("LEFT", specmenu, 190, 0)
	specmenu.Lable:SetText("Select Specialization")
	specmenu:SetScript("OnClick", self.Options_UpateDB_OnClick)

	local favorite1 = CreateFrame("Button", "SpecMenuOptions_favorite1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    favorite1:SetPoint("TOPLEFT", 15, -95)
	favorite1.Lable = favorite1:CreateFontString(nil , "BORDER", "GameFontNormal")
	favorite1.Lable:SetJustifyH("LEFT")
	favorite1.Lable:SetPoint("LEFT", favorite1, 190, 0)
	favorite1.Lable:SetText("Favorite Left Click")

	local favorite2 = CreateFrame("Button", "SpecMenuOptions_favorite2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    favorite2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -130)
	favorite2.Lable = favorite2:CreateFontString(nil , "BORDER", "GameFontNormal")
	favorite2.Lable:SetJustifyH("LEFT")
	favorite2.Lable:SetPoint("LEFT", favorite2, 190, 0)
	favorite2.Lable:SetText("Favorite Right Click")

	local hideMenu = CreateFrame("CheckButton", "SpecMenuOptions_HideMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideMenu:SetPoint("TOPLEFT", 15, -200)
	hideMenu.Lable = hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMenu.Lable:SetJustifyH("LEFT")
	hideMenu.Lable:SetPoint("LEFT", 30, 0)
	hideMenu.Lable:SetText("Hide Main Menu")
	hideMenu:SetScript("OnClick", function() 
		if self.db.HideMenu then
			SpecMenuFrame:Show()
			self.db.HideMenu = false
		else
			SpecMenuFrame:Hide()
			self.db.HideMenu = true
		end
	end)

	local hideHover = CreateFrame("CheckButton", "SpecMenuOptions_ShowOnHover", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideHover:SetPoint("TOPLEFT", 15, -235)
	hideHover.Lable = hideHover:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideHover.Lable:SetJustifyH("LEFT")
	hideHover.Lable:SetPoint("LEFT", 30, 0)
	hideHover.Lable:SetText("Only show menu button on mouse over")
	hideHover:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Only shows the main menu button on mouse over")
        GameTooltip:Show()
    end)
    hideHover:SetScript("OnLeave", function() GameTooltip:Hide() end)
	hideHover:SetScript("OnClick", function()
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

	local autoMenu = CreateFrame("CheckButton", "SpecMenuOptions_AutoMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	autoMenu:SetPoint("TOPLEFT", 15, -270)
	autoMenu.Lable = autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	autoMenu.Lable:SetJustifyH("LEFT")
	autoMenu.Lable:SetPoint("LEFT", 30, 0)
	autoMenu.Lable:SetText("Auto open menu of mouse over")
	autoMenu:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -(self:GetWidth() / 2), 5)
        GameTooltip:AddLine("Auto opens the menu when you mouse over the button. \nHolding alt will open the enchant specs menu")
        GameTooltip:Show()
    end)
    autoMenu:SetScript("OnLeave", function() GameTooltip:Hide() end)
	autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	local hideMinimap = CreateFrame("CheckButton", "SpecMenuOptions_HideMinimap", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideMinimap:SetPoint("TOPLEFT", 15, -305)
	hideMinimap.Lable = hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMinimap.Lable:SetJustifyH("LEFT")
	hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	hideMinimap.Lable:SetText("Hide Minimap Icon")
	hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	local hideSpecDisplay = CreateFrame("CheckButton", "SpecMenuOptions_HideSpecDisplay", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideSpecDisplay:SetPoint("TOPLEFT", 380, -55)
	hideSpecDisplay.Lable = hideSpecDisplay:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideSpecDisplay.Lable:SetJustifyH("LEFT")
	hideSpecDisplay.Lable:SetPoint("LEFT", 30, 0)
	hideSpecDisplay.Lable:SetText("Hide Spec/Enchant Display")
	hideSpecDisplay:SetScript("OnClick", function()
		self.db.hideSpecDisplay = not self.db.hideSpecDisplay
		self:CreateSpecDisplay()
		if self.db.hideSpecDisplay then
			SpecDisplayFrame:Hide()
		else
			SpecDisplayFrame:Show()
			SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
		end
	end)

	local hideSpecDisplayBackground = CreateFrame("CheckButton", "SpecMenuOptions_HideSpecDisplayBackground", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideSpecDisplayBackground:SetPoint("TOPLEFT", 380, -90)
	hideSpecDisplayBackground.Lable = hideSpecDisplayBackground:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideSpecDisplayBackground.Lable:SetJustifyH("LEFT")
	hideSpecDisplayBackground.Lable:SetPoint("LEFT", 30, 0)
	hideSpecDisplayBackground.Lable:SetText("Hide Spec/Enchant Display Background")
	hideSpecDisplayBackground:SetScript("OnClick", function()
		self.db.hideSpecDisplayBackground = not self.db.hideSpecDisplayBackground
		if self.db.hideSpecDisplayBackground then
			SpecDisplayFrame:SetBackdropColor(0, 0, 0, 0)
			SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 0)
		else
			SpecDisplayFrame:SetBackdropColor(0, 0, 0, 5)
			SpecDisplayFrame:SetBackdropBorderColor(0, 0, 0, 5)
		end
	end)

	local displayScale = CreateFrame("Slider", "SpecMenuOptionsDisplayScale", SpecMenuOptionsFrame,"OptionsSliderTemplate")
		displayScale:SetSize(240,16)
		displayScale:SetPoint("TOPLEFT", 380,-140)
		displayScale:SetMinMaxValues(0.25, 1.5)
		_G[displayScale:GetName().."Text"]:SetText("Spec Display Scale: ".." ("..round(displayScale:GetValue(),2)..")")
		_G[displayScale:GetName().."Low"]:SetText(0.25)
		_G[displayScale:GetName().."High"]:SetText(1.5)
		displayScale:SetValueStep(0.01)
		displayScale:SetScript("OnShow", function() displayScale:SetValue(self.db.SpecDisplayScale) end)
        displayScale:SetScript("OnValueChanged", function()
			_G[displayScale:GetName().."Text"]:SetText("Spec Display Scale: ".." ("..round(displayScale:GetValue(),2)..")")
            self.db.SpecDisplayScale = displayScale:GetValue()
			if SpecDisplayFrame then
            	SpecDisplayFrame:SetScale(self.db.SpecDisplayScale)
				self:SetDisplayText()
			end
        end)

	local txtSize = CreateFrame("Button", "SpecMenuOptions_TxtSizeMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
		txtSize:SetPoint("TOPLEFT", 15, -340)
		txtSize.Lable = txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
		txtSize.Lable:SetJustifyH("LEFT")
		txtSize.Lable:SetPoint("LEFT", txtSize, 190, 0)
		txtSize.Lable:SetText("Menu Text Size")
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