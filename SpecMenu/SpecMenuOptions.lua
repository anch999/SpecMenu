local specmenu_options_swap = "Last Active Spec";
local quickSwapNum = "";
local lastSpecPos
local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

function SPM:Options_Toggle()
	if not SPM.OptionsLoaded then
		SPM:Options_CreateFrame();
	end
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

	SpMenuSpecNum = thisID;
	SpecMenu_QuickswapNum1 = SPM.db.Specs[thisID][1];
	SpecMenu_QuickswapNum2 = SPM.db.Specs[thisID][2];
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
	SpecMenuOptions_PresetSet = thisID;
end

local function options_PresetMenu_Initialize()
	--Loads the enchant preset list into the enchant preset dropdown menu
	local info;
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
		SpecMenu_QuickswapNum1 = "LastSpec";
		SPM.db.Specs[SpMenuSpecNum][1] = "LastSpec";
	elseif quickSwapNum == "2" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
		SpecMenu_QuickswapNum2 = "LastSpec";
		SPM.db.Specs[SpMenuSpecNum][2] = "LastSpec";
	end
end

local function options_QuickSwap1_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
	SpecMenu_QuickswapNum1 = thisID;
	SPM.db.Specs[SpMenuSpecNum][1] = SpecMenu_QuickswapNum1;
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
	SpecMenu_QuickswapNum2 = thisID;
	SPM.db.Specs[SpMenuSpecNum][2] = SpecMenu_QuickswapNum2;
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

local function dropDownInitialize()
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
		UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM.specName[SpMenuSpecNum]);
end

function SpecMenuOptions_OpenOptions()
	if IsSpellKnown(SPM.SpecInfo[1]) then
			local menuID = SPM:SpecId();
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, menuID);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SPM.db.Specs[menuID][1]);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SPM.db.Specs[menuID][2]);

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

			UIDropDownMenu_SetText(SpecMenuOptions_Menu, SPM.specName[menuID]);
			SpMenuSpecNum = menuID;
			SpecMenu_QuickswapNum1 = SPM.db.Specs[menuID][1];
			SpecMenu_QuickswapNum2 = SPM.db.Specs[menuID][2];
	end
		local presetID = SPM:PresetId();
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, presetID);
		UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SPM.enchantSetsDB[presetID].name or ("Enchants Set "..presetID));
		SpecMenuOptions_PresetSet = presetID;
end

--Creates the options frame and all its assets
function SPM:Options_CreateFrame()
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
	specmenu.Lable:SetPoint("TOPLEFT", specmenu, "TOPLEFT", 20, 20)
	specmenu.Lable:SetText("Select Spec To Edit")
	specmenu:SetScript("OnClick", SpecMenuOptions_UpateDB_OnClick);

	local quickswap1 = CreateFrame("Button", "SpecMenuOptions_QuickSwap1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap1:SetPoint("TOPLEFT", 190, -60);
	quickswap1.Lable = quickswap1:CreateFontString(nil , "BORDER", "GameFontNormal")
	quickswap1.Lable:SetJustifyH("RIGHT")
	quickswap1.Lable:SetPoint("TOPLEFT", quickswap1, "TOPLEFT", 20, 20)
	quickswap1.Lable:SetText("QuickSwap Left Click")

	local quickswap2 = CreateFrame("Button", "SpecMenuOptions_QuickSwap2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 190, -89);
	quickswap2.Lable = quickswap2:CreateFontString(nil , "BORDER", "GameFontNormal")
	quickswap2.Lable:SetJustifyH("RIGHT")
	quickswap2.Lable:SetPoint("BOTTOMLEFT", quickswap2, "BOTTOMLEFT", 20, -20)
	quickswap2.Lable:SetText("QuickSwap Right Click")

	local presetmenu = CreateFrame("Button", "SpecMenuOptions_PresetMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    presetmenu:SetPoint("TOPLEFT", 15, -180);
	presetmenu.Lable = presetmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	presetmenu.Lable:SetJustifyH("RIGHT")
	presetmenu.Lable:SetPoint("TOPLEFT", presetmenu, "TOPLEFT", 20, 20)
	presetmenu.Lable:SetText("Select Enchant Preset To Edit")

	dropDownInitialize();
	SPM.OptionsLoaded = true
end

