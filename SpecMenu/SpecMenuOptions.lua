local specmenu_options_swap = "Last Active Spec";
local quickSwapNum = "";
local lastSpecPos

function SpecMenuOptions_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu");
	end
end

local function SpecMenuOptions_Menu_OnClick()
    local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, thisID);
	SpecMenuOptions_NameEdit:SetText(SpecMenuDB["Specs"][thisID][1])
	
	if SpecMenuDB["Specs"][thisID][2] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, lastSpecPos);
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][thisID][2]);
	end
	
	if SpecMenuDB["Specs"][thisID][3] == "LastSpec" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, lastSpecPos);
	else
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][thisID][3]);
	end
	
	SpMenuSpecNum = thisID;
	SpecMenu_QuickswapNum1 = SpecMenuDB["Specs"][thisID][2];
	SpecMenu_QuickswapNum2 = SpecMenuDB["Specs"][thisID][3];
end

local function SpecMenuOptions_Menu_Initialize()
    local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
				info = {
					text = SpecMenuDB["Specs"][k][1];
					func = SpecMenuOptions_Menu_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

local function SpecMenuOptions_NameEditCheckToggle()
	if SpecMenuOptions_NameEditCheck:GetChecked() then
		SpecMenuDB["EditAscenSpec"] = SpecMenuOptions_NameEditCheck:GetChecked()
	else
		SpecMenuDB["EditAscenSpec"] = SpecMenuOptions_NameEditCheck:GetChecked()
	end
end

local function SpecMenuOptions_PresetNameEditCheckToggle()
	if SpecMenuOptions_PresetNameEditCheck:GetChecked() then
		SpecMenuDB["EditAscenPreset"] = SpecMenuOptions_PresetNameEditCheck:GetChecked()
	else
		SpecMenuDB["EditAscenPreset"] = SpecMenuOptions_PresetNameEditCheck:GetChecked()
	end
end

local function SpecMenuOptions_PresetNameEdit_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, thisID);
	SpecMenuOptions_PresetNameEdit:SetText(SpecMenuDB["EnchantPresets"][thisID]);
	SpecMenuOptions_PresetSet = thisID;
end

local function SpecMenuOptions_PresetMenu_Initialize()
	--Loads the enchant preset list into the enchant preset dropdown menu
	local info;
	for k,v in pairs(SpecMenuDB["EnchantPresets"]) do
		info = {
					text = SpecMenuDB["EnchantPresets"][k];
					func = SpecMenuOptions_PresetNameEdit_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

local function SpecMenuOptions_QuickSwapLastSpec_OnClick(num)
	local thisID = this:GetID();
	if quickSwapNum == "1" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
		SpecMenu_QuickswapNum1 = "LastSpec";
		SpecMenuDB["Specs"][SpMenuSpecNum][2] = "LastSpec";
	elseif quickSwapNum == "2" then
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
		SpecMenu_QuickswapNum2 = "LastSpec";
		SpecMenuDB["Specs"][SpMenuSpecNum][3] = "LastSpec";
	end
end

local function SpecMenuOptions_QuickSwap1_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
	SpecMenu_QuickswapNum1 = thisID;
	SpecMenuDB["Specs"][SpMenuSpecNum][2] = SpecMenu_QuickswapNum1;
	
end

local function SpecMenuOptions_QuickSwap1_Initialize()
	--Loads the spec list into the quickswap1 dropdown menu
	local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
		info = {
					text = SpecMenuDB["Specs"][k][1];
					func = SpecMenuOptions_QuickSwap1_OnClick;
				};
					UIDropDownMenu_AddButton(info);
					lastSpecPos = k + 1
	end
	--Adds Lastspec as the last entry on the quickswap1 dropdown menu 
	info = {
		text = specmenu_options_swap;
		func = SpecMenuOptions_QuickSwapLastSpec_OnClick;
	};
		UIDropDownMenu_AddButton(info);
		quickSwapNum = "1"
end

local function SpecMenuOptions_QuickSwap2_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
	SpecMenu_QuickswapNum2 = thisID;
	SpecMenuDB["Specs"][SpMenuSpecNum][3] = SpecMenu_QuickswapNum2;
end

function SpecMenuOptions_QuickSwap2_Initialize()
	--Loads the spec list into the quickswap2 dropdown menu
	local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
		info = {
			text = SpecMenuDB["Specs"][k][1];
			func = SpecMenuOptions_QuickSwap2_OnClick;
		};
			UIDropDownMenu_AddButton(info);
			lastSpecPos = k + 1
	end
	--Adds Lastspec as the last entry on the quickswap2 dropdown menu 
	info = {
		text = specmenu_options_swap;
		func = SpecMenuOptions_QuickSwapLastSpec_OnClick;
	};
		UIDropDownMenu_AddButton(info);
		quickSwapNum = "2"

end

local function SpecMenu_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(SpecMenuOptions_Menu, SpecMenuOptions_Menu_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu);
	UIDropDownMenu_SetWidth(SpecMenuOptions_Menu, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_QuickSwap1, SpecMenuOptions_QuickSwap1_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1);
	UIDropDownMenu_SetWidth(SpecMenuOptions_QuickSwap1, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_QuickSwap2, SpecMenuOptions_QuickSwap2_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2);
	UIDropDownMenu_SetWidth(SpecMenuOptions_QuickSwap2, 150);

	UIDropDownMenu_Initialize(SpecMenuOptions_PresetMenu, SpecMenuOptions_PresetMenu_Initialize);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu);
	UIDropDownMenu_SetWidth(SpecMenuOptions_PresetMenu, 150);
end

local function SpecMenuOptions_UpatePresetDB_OnClick()
	--Updates the name of the Enchant Preset selected
	SpecMenuDB["EnchantPresets"][SpecMenuOptions_PresetSet] = SpecMenuOptions_PresetNameEdit:GetText();
	UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SpecMenuDB["EnchantPresets"][SpecMenuOptions_PresetSet]);
	--Overwrites   the ascension Enchant Preset names if checkbox is selected
	if SpecMenuDB["EditAscenPreset"] then
		if AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet].name then
			AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet].name = SpecMenuOptions_PresetNameEdit:GetText();
		else
			AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet] = {"name"}
			AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet].name = SpecMenuOptions_PresetNameEdit:GetText();
		end
			--If there is no icon selected it will update it to the default otherwise the updated names wont show
			if AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet].icon == nil then
				AscensionUI_CDB["EnchantManager"]["presets"][SpecMenuOptions_PresetSet].icon = "Interface\\Icons\\inv_misc_book_16";
			end
	end
end

local function SpecMenuOptions_UpateDB_OnClick()
	--Updates the name of the Spec selected
	if SpecMenu_EnableMenu() then
	SpecMenuDB["Specs"][SpMenuSpecNum][1] = SpecMenuOptions_NameEdit:GetText();
	UIDropDownMenu_SetText(SpecMenuOptions_Menu, SpecMenuDB["Specs"][SpMenuSpecNum][1]);
	--Overwrites the ascension Spec names if checkbox is selected
	if SpecMenuDB["EditAscenSpec"] then
		AscensionUI_CDB["CA2"]["SpecNamesCustom"][SpMenuSpecNum] = SpecMenuOptions_NameEdit:GetText();
			--If there is no icon selected it will update it to the default otherwise the updated names wont show
			if AscensionUI_CDB["CA2"]["SpecIconsCustom"][SpMenuSpecNum] == nil then
				AscensionUI_CDB["CA2"]["SpecIconsCustom"][SpMenuSpecNum] = "Interface\\Icons\\inv_misc_book_16";
			end
	end
	end

end

local function SpecMenuOptions_SpecSetup()
	local menuID = SpecMenu_SpecId();
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, menuID);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][menuID][2]);
			UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][menuID][3]);
			SpecMenuOptions_NameEdit:SetText(SpecMenuDB["Specs"][menuID][1])
		if SpecMenuDB["Specs"][menuID][2] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap1, specmenu_options_swap);
		else
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][SpecMenuDB["Specs"][menuID][2]][1] or "You don't have more then 1 spec");
		end
		if SpecMenuDB["Specs"][menuID][3] == "LastSpec" then
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, specmenu_options_swap);
		else
			UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][SpecMenuDB["Specs"][menuID][3]][1]);
		end
			UIDropDownMenu_SetText(SpecMenuOptions_Menu, SpecMenuDB["Specs"][menuID][1]);
			SpMenuSpecNum = menuID;
			SpecMenu_QuickswapNum1 = SpecMenuDB["Specs"][menuID][2];
			SpecMenu_QuickswapNum2 = SpecMenuDB["Specs"][menuID][3];
end

function SpecMenuOptions_OpenOptions()
	if SpecMenu_EnableMenu() then
		SpecMenuOptions_SpecSetup();
	end
		local presetID = SpecMenu_PresetId();
		UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, presetID);
		UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SpecMenuDB["EnchantPresets"][presetID]);
		if SpecMenuDB["EnchantPresets"][presetID] ~= nil then
		SpecMenuOptions_PresetNameEdit:SetText(SpecMenuDB["EnchantPresets"][presetID]);
		end
		SpecMenuOptions_PresetSet = presetID;
		SpecMenuOptions_NameEditCheck:SetChecked(SpecMenuDB["EditAscenSpec"])
		SpecMenuOptions_PresetNameEditCheck:SetChecked(SpecMenuDB["EditAscenPreset"])
end

--Creates the options frame and all its assets
function SpecMenuOptions_CreateFrame()
	local mainframe = CreateFrame("FRAME", "SpecMenuOptionsFrame", InterfaceOptionsFrame, nil);
    local fstring = mainframe:CreateFontString(mainframe, "OVERLAY", "GameFontNormal");
	fstring:SetText("Spec Menu Settings");
	fstring:SetPoint("TOPLEFT", 15, -15)
	mainframe.name = "SpecMenu";
	InterfaceOptions_AddCategory(mainframe);
	InterfaceOptionsFrame:SetWidth(850)

	local editbox1 = CreateFrame("EditBox", "SpecMenuOptions_NameEdit", SpecMenuOptionsFrame, "InputBoxTemplate");
    editbox1:SetWidth(160);
    editbox1:SetHeight(24);
    editbox1:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 39, -89);
    editbox1:SetAutoFocus(false);
    editbox1:SetMaxLetters(30);
	editbox1:SetScript("OnTextChanged", SpecMenuOptions_UpateDB_OnClick);

	local specmenu = CreateFrame("Button", "SpecMenuOptions_Menu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    specmenu:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -60);
	specmenu.Lable = specmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	specmenu.Lable:SetJustifyH("RIGHT")
	specmenu.Lable:SetPoint("TOPLEFT", specmenu, "TOPLEFT", 20, 20)
	specmenu.Lable:SetText("Select Spec To Edit")
	specmenu:SetScript("OnClick", SpecMenuOptions_UpateDB_OnClick);

	local quickswap1 = CreateFrame("Button", "SpecMenuOptions_QuickSwap1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap1:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 190, -60);
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

	local editbox2 = CreateFrame("EditBox", "SpecMenuOptions_PresetNameEdit", SpecMenuOptionsFrame, "InputBoxTemplate");
    editbox2:SetWidth(160);
    editbox2:SetHeight(24);
    editbox2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 39, -209);
    editbox2:SetAutoFocus(false);
    editbox2:SetMaxLetters(30);
	editbox2:SetScript("OnTextChanged", SpecMenuOptions_UpatePresetDB_OnClick);

	local presetmenu = CreateFrame("Button", "SpecMenuOptions_PresetMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    presetmenu:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -180);
	presetmenu.Lable = presetmenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	presetmenu.Lable:SetJustifyH("RIGHT")
	presetmenu.Lable:SetPoint("TOPLEFT", presetmenu, "TOPLEFT", 20, 20)
	presetmenu.Lable:SetText("Select Enchant Preset To Edit")

	local updateAscenUI1 = CreateFrame("CheckButton", "SpecMenuOptions_NameEditCheck", SpecMenuOptionsFrame, "OptionsCheckButtonTemplate")
	updateAscenUI1:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 5, -89);
	updateAscenUI1:SetWidth(25)
	updateAscenUI1:SetHeight(25)
	updateAscenUI1:SetScript("OnClick", SpecMenuOptions_NameEditCheckToggle);
	updateAscenUI1:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("Overwrite Ascension Spec Names")
		GameTooltip:Show()
	end)
	updateAscenUI1:SetScript("OnLeave", function() GameTooltip:Hide() end)

	local updateAscenUI2 = CreateFrame("CheckButton", "SpecMenuOptions_PresetNameEditCheck", SpecMenuOptionsFrame, "OptionsCheckButtonTemplate")
	updateAscenUI2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 5, -209);
	updateAscenUI2:SetWidth(25)
	updateAscenUI2:SetHeight(25)
	updateAscenUI2:SetScript("OnClick", SpecMenuOptions_PresetNameEditCheckToggle);
	updateAscenUI2:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("Overwrite Ascension Preset Names")
		GameTooltip:Show()
	end)
	updateAscenUI2:SetScript("OnLeave", function() GameTooltip:Hide() end)

	SpecMenu_DropDownInitialize();
	SpecMenuOptions_OpenOptions();
end

