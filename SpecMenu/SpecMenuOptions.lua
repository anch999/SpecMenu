local specmenu_options_swap = "Last Active Spec"
local favoriteNum = ""
local lastSpecPos
local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

function SPM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu")
	end
end

local function options_Menu_OnClick()
    local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, thisID)

	if SPM.db.Specs[thisID][1] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, lastSpecPos)
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, SPM.db.Specs[thisID][1])
	end

	if SPM.db.Specs[thisID][2] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, lastSpecPos)
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, SPM.db.Specs[thisID][2])
	end

	SPM.optionsSpecNum = thisID
end

local function options_Menu_Initialize()
    local info
	for i,_ in ipairs(SPM.db.Specs) do
				info = {
					text = SPM:GetSpecInfo(i),
					func = options_Menu_OnClick,
				}
					UIDropDownMenu_AddButton(info)
	end
end

local function options_favoriteLastSpec_OnClick(num)
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

local function options_favorite1_OnClick()
	local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1, thisID)
	SPM.db.Specs[SPM.optionsSpecNum][1] = thisID
end

local function options_favorite1_Initialize()
	--Loads the spec list into the favorite1 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
					text = SPM:GetSpecInfo(i),
					func = options_favorite1_OnClick,
				}
					UIDropDownMenu_AddButton(info)
					lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the favorite1 dropdown menu 
	info = {
		text = specmenu_options_swap,
		func = options_favoriteLastSpec_OnClick,
	}
		UIDropDownMenu_AddButton(info)
		favoriteNum = "1"
end

local function options_favorite2_OnClick()
	local thisID = this:GetID()
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2, thisID)
	SPM.db.Specs[SPM.optionsSpecNum][2] = thisID
end

function SPM:Options_favorite2_Initialize()
	--Loads the spec list into the favorite2 dropdown menu
	local info
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
			text = SPM:GetSpecInfo(i),
			func = options_favorite2_OnClick,
		}
			UIDropDownMenu_AddButton(info)
			lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the favorite2 dropdown menu 
	info = {
		text = specmenu_options_swap,
		func = options_favoriteLastSpec_OnClick,
	}
		UIDropDownMenu_AddButton(info)
		favoriteNum = "2"

end

function SPM:DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(SpecMenuOptions_Menu, options_Menu_Initialize)
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu)
	UIDropDownMenu_SetWidth(SpecMenuOptions_Menu, 150)

	UIDropDownMenu_Initialize(SpecMenuOptions_favorite1, options_favorite1_Initialize)
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite1)
	UIDropDownMenu_SetWidth(SpecMenuOptions_favorite1, 150)

	UIDropDownMenu_Initialize(SpecMenuOptions_favorite2, SPM.Options_favorite2_Initialize)
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_favorite2)
	UIDropDownMenu_SetWidth(SpecMenuOptions_favorite2, 150)

end

local function SpecMenuOptions_UpateDB_OnClick()
		--Updates the name of the Spec selected
		if not CA_IsSpellKnown(SPM.SpecInfo[1]) then return end
		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM:GetSpecInfo(SPM.optionsSpecNum))
end

function SPM:OpenOptions()
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
	specmenu:SetScript("OnClick", SpecMenuOptions_UpateDB_OnClick)

	local favorite1 = CreateFrame("Button", "SpecMenuOptions_favorite1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    favorite1:SetPoint("TOPLEFT", 15, -95)
	favorite1.Lable = favorite1:CreateFontString(nil , "BORDER", "GameFontNormal")
	favorite1.Lable:SetJustifyH("LEFT")
	favorite1.Lable:SetPoint("LEFT", favorite1, 190, 0)
	favorite1.Lable:SetText("favorite Left Click")

	local favorite2 = CreateFrame("Button", "SpecMenuOptions_favorite2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate")
    favorite2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -130)
	favorite2.Lable = favorite2:CreateFontString(nil , "BORDER", "GameFontNormal")
	favorite2.Lable:SetJustifyH("LEFT")
	favorite2.Lable:SetPoint("LEFT", favorite2, 190, 0)
	favorite2.Lable:SetText("favorite Right Click")

	local hideMenu = CreateFrame("CheckButton", "SpecMenuOptions_HideMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideMenu:SetPoint("TOPLEFT", 15, -235)
	hideMenu.Lable = hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMenu.Lable:SetJustifyH("LEFT")
	hideMenu.Lable:SetPoint("LEFT", 30, 0)
	hideMenu.Lable:SetText("Hide Main Menu")
	hideMenu:SetScript("OnClick", function() 
		if SPM.db.HideMenu then
			SpecMenuFrame:Show()
			SPM.db.HideMenu = false
		else
			SpecMenuFrame:Hide()
			SPM.db.HideMenu = true
		end
	end)

	local hideHover = CreateFrame("CheckButton", "SpecMenuOptions_ShowOnHover", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideHover:SetPoint("TOPLEFT", 15, -270)
	hideHover.Lable = hideHover:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideHover.Lable:SetJustifyH("LEFT")
	hideHover.Lable:SetPoint("LEFT", 30, 0)
	hideHover.Lable:SetText("Only Show Menu on Hover")
	hideHover:SetScript("OnClick", function()
		if SPM.db.ShowMenuOnHover then
			SpecMenuFrame_Menu:Show()
            SpecMenuFrame_Favorite:Show()
            SpecMenuFrame.icon:Show()
			SpecMenuFrame.Text:Show()
			SPM.db.ShowMenuOnHover = false
		else
			SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_Favorite:Hide()
            SpecMenuFrame.icon:Hide()
			SpecMenuFrame.Text:Hide()
			SPM.db.ShowMenuOnHover = true
		end

	end)

	local hideMinimap = CreateFrame("CheckButton", "SpecMenuOptions_HideMinimap", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideMinimap:SetPoint("TOPLEFT", 15, -305)
	hideMinimap.Lable = hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideMinimap.Lable:SetJustifyH("LEFT")
	hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	hideMinimap.Lable:SetText("Hide Minimap Icon")
	hideMinimap:SetScript("OnClick", function() SPM:ToggleMinimap() end)
	
	local hideSpecDisplay = CreateFrame("CheckButton", "SpecMenuOptions_HideMinimap", SpecMenuOptionsFrame, "UICheckButtonTemplate")
	hideSpecDisplay:SetPoint("TOPLEFT", 15, -340)
	hideSpecDisplay.Lable = hideSpecDisplay:CreateFontString(nil , "BORDER", "GameFontNormal")
	hideSpecDisplay.Lable:SetJustifyH("LEFT")
	hideSpecDisplay.Lable:SetPoint("LEFT", 30, 0)
	hideSpecDisplay.Lable:SetText("Hide Spec/Enchant Display")
	hideSpecDisplay:SetScript("OnClick", function()
		SPM.db.hideSpecDisplay = not SPM.db.hideSpecDisplay
		SPM:CreateSpecDisplay()
		if SPM.db.hideSpecDisplay then
			SpecDisplayFrame:Hide()
		else
			SpecDisplayFrame:Show()
		end
	end)
