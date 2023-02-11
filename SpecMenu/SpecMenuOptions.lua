local specmenu_options_swap = "Last Active Spec";
local quickSwapNum = "";
local lastSpecPos
local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

function SPM:Options_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu");
	end
end

local function options_Menu_OnClick()
    local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, thisID);

	if SPM.db.Specs[thisID][1] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, lastSpecPos);
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SPM.db.Specs[thisID][1]);
	end

	if SPM.db.Specs[thisID][2] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, lastSpecPos);
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SPM.db.Specs[thisID][2]);
	end

	local presetID = SPM.db.Specs[thisID][3];
	if presetID then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, presetID);
		UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SPM.enchantSetsDB[SPM.db.Specs[thisID][3]-1].name);

	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, 1);
		UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, "None");
	end

	SPM.optionsSpecNum = thisID;
end

local function options_Menu_Initialize()
    local info;
	for i,_ in ipairs(SPM.db.Specs) do
				info = {
					text = SPM.specName[i] or ("Specialization "..i);
					func = options_Menu_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

local function options_PresetNameEdit_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, thisID);
	if thisID == 1 then
		SPM.db.Specs[SPM.optionsSpecNum][3] = false
	else
		SPM.db.Specs[SPM.optionsSpecNum][3] = thisID
	end
end

local function options_PresetMenu_Initialize()
	--Loads the enchant preset list into the enchant preset dropdown menu
	local info;
	info = {
		text = "None";
		func = options_PresetNameEdit_OnClick;
	};
		UIDropDownMenu_AddButton(info);
	for i,_ in ipairs(SPM.db.EnchantPresets) do
		info = {
					text = SPM.enchantSetsDB[i].name or ("Enchants Set "..i);
					func = options_PresetNameEdit_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

local function options_QuickSwapLastSpec_OnClick(num)
	local thisID = this:GetID();
	if quickSwapNum == "1" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
		SPM.db.Specs[SPM.optionsSpecNum][1] = "LastSpec";
	elseif quickSwapNum == "2" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
		SpecMenu_QuickswapNum2 = "LastSpec";
		SPM.db.Specs[SPM.optionsSpecNum][2] = "LastSpec";
	end
end

local function options_QuickSwap1_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
	SPM.db.Specs[SPM.optionsSpecNum][1] = thisID;
end

local function options_QuickSwap1_Initialize()
	--Loads the spec list into the quickswap1 dropdown menu
	local info;
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
					text = SPM.specName[i] or ("Specialization "..i);
					func = options_QuickSwap1_OnClick;
				};
					UIDropDownMenu_AddButton(info);
					lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the quickswap1 dropdown menu 
	info = {
		text = specmenu_options_swap;
		func = options_QuickSwapLastSpec_OnClick;
	};
		UIDropDownMenu_AddButton(info);
		quickSwapNum = "1"
end

local function options_QuickSwap2_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
	SPM.db.Specs[SPM.optionsSpecNum][2] = thisID;
end

function SPM:Options_QuickSwap2_Initialize()
	--Loads the spec list into the quickswap2 dropdown menu
	local info;
	for i,_ in ipairs(SPM.db.Specs) do
		info = {
			text = SPM.specName[i] or ("Specialization "..i);
			func = options_QuickSwap2_OnClick;
		};
			UIDropDownMenu_AddButton(info);
			lastSpecPos = i + 1
	end
	--Adds Lastspec as the last entry on the quickswap2 dropdown menu 
	info = {
		text = specmenu_options_swap;
		func = options_QuickSwapLastSpec_OnClick;
	};
		UIDropDownMenu_AddButton(info);
		quickSwapNum = "2"

end

function SPM:DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(SpecMenuOptions_Menu, options_Menu_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu);
	UIDropDownMenu_SetWidth(SpecMenuOptions_Menu, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_QuickSwap1, options_QuickSwap1_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1);
	UIDropDownMenu_SetWidth(SpecMenuOptions_QuickSwap1, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_QuickSwap2, SPM.Options_QuickSwap2_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2);
	UIDropDownMenu_SetWidth(SpecMenuOptions_QuickSwap2, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_PresetMenu, options_PresetMenu_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu);
	UIDropDownMenu_SetWidth(SpecMenuOptions_PresetMenu, 150);
end

local function SpecMenuOptions_UpateDB_OnClick()
		--Updates the name of the Spec selected
		if not IsSpellKnown(SPM.SpecInfo[1]) then return end
		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM.specName[SPM.optionsSpecNum]);
end

function SpecMenuOptions_OpenOptions()
	if IsSpellKnown(SPM.SpecInfo[1]) then
			local menuID = SPM:SpecId();
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, menuID);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SPM.db.Specs[menuID][1]);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SPM.db.Specs[menuID][2]);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, SPM.db.Specs[menuID][3] or 1);

		if SPM.db.Specs[menuID][1] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap1, specmenu_options_swap);
		else
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap1, SPM.specName[SPM.db.Specs[menuID][1]]);
		end

		if SPM.db.Specs[menuID][2] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, specmenu_options_swap);
		else
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, SPM.specName[SPM.db.Specs[menuID][2]]);
		end

		if SPM.db.Specs[menuID][3] then
			UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SPM.enchantSetsDB[SPM.db.Specs[menuID][3]-1].name);
		else
			UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, "None");
		end

		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM.specName[menuID]);
		SPM.optionsSpecNum = menuID;
	end
end

--Creates the options frame and all its assets
	InterfaceOptionsFrame:SetWidth(850)
	local mainframe = {};
		mainframe.panel = CreateFrame("FRAME", "SpecMenuOptionsFrame", UIParent, nil);
    	local fstring = mainframe.panel:CreateFontString(mainframe, "OVERLAY", "GameFontNormal");
		fstring:SetText("Spec Menu Settings");
		fstring:SetPoint("TOPLEFT", 15, -15)
		mainframe.panel.name = "SpecMenu";
		InterfaceOptions_AddCategory(mainframe.panel);

	local specmenu = CreateFrame("Button", "SpecMenuOptions_Menu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    specmenu:SetPoint("TOPLEFT", 15, -60);
	specmenu.Lable = specmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	specmenu.Lable:SetJustifyH("LEFT")
	specmenu.Lable:SetPoint("LEFT", specmenu, 190, 0)
	specmenu.Lable:SetText("Select Specialization")
	specmenu:SetScript("OnClick", SpecMenuOptions_UpateDB_OnClick);

	local quickswap1 = CreateFrame("Button", "SpecMenuOptions_QuickSwap1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap1:SetPoint("TOPLEFT", 15, -95);
	quickswap1.Lable = quickswap1:CreateFontString(nil , "BORDER", "GameFontNormal")
	quickswap1.Lable:SetJustifyH("LEFT")
	quickswap1.Lable:SetPoint("LEFT", quickswap1, 190, 0)
	quickswap1.Lable:SetText("QuickSwap Left Click")

	local quickswap2 = CreateFrame("Button", "SpecMenuOptions_QuickSwap2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -130);
	quickswap2.Lable = quickswap2:CreateFontString(nil , "BORDER", "GameFontNormal")
	quickswap2.Lable:SetJustifyH("LEFT")
	quickswap2.Lable:SetPoint("LEFT", quickswap2, 190, 0)
	quickswap2.Lable:SetText("QuickSwap Right Click")

	local presetmenu = CreateFrame("Button", "SpecMenuOptions_PresetMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    presetmenu:SetPoint("TOPLEFT", 15, -165);
	presetmenu.Lable = presetmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	presetmenu.Lable:SetJustifyH("LEFT")
	presetmenu.Lable:SetPoint("LEFT", presetmenu, 190, 0)
	presetmenu.Lable:SetText("Select Enchant Set")

	local hideMenu = CreateFrame("CheckButton", "SpecMenuOptions_HideMenu", SpecMenuOptionsFrame, "UICheckButtonTemplate");
	hideMenu:SetPoint("TOPLEFT", 15, -235);
	hideMenu.Lable = hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal");
	hideMenu.Lable:SetJustifyH("LEFT");
	hideMenu.Lable:SetPoint("LEFT", 30, 0);
	hideMenu.Lable:SetText("Hide Main Menu");
	hideMenu:SetScript("OnClick", function() 
		if SPM.db.HideMenu then
			SpecMenuFrame:Show()
			SPM.db.HideMenu = false
		else
			SpecMenuFrame:Hide()
			SPM.db.HideMenu = true
		end
	end);

	local hideHover = CreateFrame("CheckButton", "SpecMenuOptions_ShowOnHover", SpecMenuOptionsFrame, "UICheckButtonTemplate");
	hideHover:SetPoint("TOPLEFT", 15, -270);
	hideHover.Lable = hideHover:CreateFontString(nil , "BORDER", "GameFontNormal");
	hideHover.Lable:SetJustifyH("LEFT");
	hideHover.Lable:SetPoint("LEFT", 30, 0);
	hideHover.Lable:SetText("Only Show Menu on Hover");
	hideHover:SetScript("OnClick", function()
		if SPM.db.ShowMenuOnHover then
			SpecMenuFrame_Menu:Show()
            SpecMenuFrame_QuickSwap:Show()
            SpecMenuFrame.icon:Show()
			SpecMenuFrame.Text:Show()
			SPM.db.ShowMenuOnHover = false
		else
			SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_QuickSwap:Hide()
            SpecMenuFrame.icon:Hide()
			SpecMenuFrame.Text:Hide()
			SPM.db.ShowMenuOnHover = true
		end

	end);

	local hideMinimap = CreateFrame("CheckButton", "SpecMenuOptions_HideMinimap", SpecMenuOptionsFrame, "UICheckButtonTemplate");
	hideMinimap:SetPoint("TOPLEFT", 15, -305);
	hideMinimap.Lable = hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal");
	hideMinimap.Lable:SetJustifyH("LEFT");
	hideMinimap.Lable:SetPoint("LEFT", 30, 0);
	hideMinimap.Lable:SetText("Hide Minimap Icon");
	hideMinimap:SetScript("OnClick", function() SPM:ToggleMinimap() end);

