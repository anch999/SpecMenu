function SpecMenu_OptionsPanelOnLoad(panel)
    panel.name="SpecMenu";
    InterfaceOptions_AddCategory(panel);
end

function SpecMenuOptions_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu");
		SpecMenuOptions_OpenOptions();
	end
end

function SpecMenuOptions_OpenOptions()
    SpecMenuOptions_NameEdit_Onload();
	SpecMenuOptions_PresetNameEdit_Onload();

end
function SpecMenuOptions_NameEdit_Onload()
	local menuID = SpecMenuDB["ActiveSpec"][1];
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, menuID);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][menuID][2]);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][menuID][3]);
	SpecMenuOptions_NameEdit:SetText(SpecMenuDB["Specs"][menuID][1])
	UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][SpecMenuDB["Specs"][menuID][2]][1]);
	UIDropDownMenu_SetText(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][SpecMenuDB["Specs"][menuID][3]][1]);
	UIDropDownMenu_SetText(SpecMenuOptions_Menu, SpecMenuDB["Specs"][menuID][1]);
	SpMenuSpecNum = menuID;
	SpecMenu_QuickswapNum1 = SpecMenuDB["Specs"][menuID][2];
	SpecMenu_QuickswapNum2 = SpecMenuDB["Specs"][menuID][3];
end

function SpecMenuOptions_PresetNameEdit_Onload()
	local presetID = SpecMenuDB["ActiveSpec"][2];
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, presetID);
	UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SpecMenuDB["EnchantPresets"][presetID]);
	SpecMenuOptions_PresetNameEdit:SetText(SpecMenuDB["EnchantPresets"][presetID]);
end

function SpecMenuOptions_Menu_Initialize()
    local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
				info = {
					text = SpecMenuDB["Specs"][k][1];
					func = SpecMenuOptions_Menu_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

function SpecMenuOptions_Menu_OnClick()
    local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_Menu, thisID);
	SpecMenuOptions_NameEdit:SetText(SpecMenuDB["Specs"][thisID][1])
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, SpecMenuDB["Specs"][thisID][2]);
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, SpecMenuDB["Specs"][thisID][3]);
	SpMenuSpecNum = thisID;
	SpecMenu_QuickswapNum1 = SpecMenuDB["Specs"][thisID][2];
	SpecMenu_QuickswapNum2 = SpecMenuDB["Specs"][thisID][3];
end

function SpecMenuOptionsFrameOnShow()
	SpecMenuOptionsCreateFrame_Initialize();
	SpecMenu_DropDownInitialize();
	SpecMenuOptions_OpenOptions();
end

function SpecMenuOptionsCreateFrame_Initialize()
		
	local editbox1 = CreateFrame("EditBox", "SpecMenuOptions_NameEdit", SpecMenuOptionsFrame, "InputBoxTemplate");
    editbox1:SetWidth(160);
    editbox1:SetHeight(24);
    editbox1:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 39, -89);
    editbox1:SetAutoFocus(false);
    editbox1:SetMaxLetters(30);

	local specmenu = CreateFrame("Button", "SpecMenuOptions_Menu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    specmenu:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -60);

	local quickswap1 = CreateFrame("Button", "SpecMenuOptions_QuickSwap1", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap1:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 190, -60);

	local quickswap2 = CreateFrame("Button", "SpecMenuOptions_QuickSwap2", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    quickswap2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 190, -89);

	local updateinfo = CreateFrame("Button", "SpecMenuOptions_UpdateDB", SpecMenuOptionsFrame, "OptionsButtonTemplate");
    updateinfo:SetWidth(160);
    updateinfo:SetHeight(50);
	updateinfo:SetText("Update Spec");
    updateinfo:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 380, -60);
	updateinfo:SetScript("OnClick", SpecMenuOptions_UpateDB_OnClick);

	local updateinfo2 = CreateFrame("Button", "SpecMenuOptions_UpatePresetDB", SpecMenuOptionsFrame, "OptionsButtonTemplate");
    updateinfo2:SetWidth(160);
    updateinfo2:SetHeight(50);
	updateinfo2:SetText("Update Enchant Preset");
    updateinfo2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 380, -160);
	updateinfo2:SetScript("OnClick", SpecMenuOptions_UpatePresetDB_OnClick);

	local editbox2 = CreateFrame("EditBox", "SpecMenuOptions_PresetNameEdit", SpecMenuOptionsFrame, "InputBoxTemplate");
    editbox2:SetWidth(160);
    editbox2:SetHeight(24);
    editbox2:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 39, -189);
    editbox2:SetAutoFocus(false);
    editbox2:SetMaxLetters(30);

	local presetmenu = CreateFrame("Button", "SpecMenuOptions_PresetMenu", SpecMenuOptionsFrame, "UIDropDownMenuTemplate");
    presetmenu:SetPoint("TOPLEFT", SpecMenuOptionsFrame, "TOPLEFT", 15, -160);

	SpecMenu_DropDownInitialize();

end

function SpecMenu_DropDownInitialize()
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

function SpecMenuOptions_PresetMenu_Initialize()
	local info;
	for k,v in pairs(SpecMenuDB["EnchantPresets"]) do
		info = {
					text = SpecMenuDB["EnchantPresets"][k];
					func = SpecMenuOptions_PresetNameEdit_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

function SpecMenuOptions_PresetNameEdit_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_PresetMenu, thisID);
	SpecMenuOptions_PresetNameEdit:SetText(SpecMenuDB["EnchantPresets"][thisID]);
	SpecMenuOptions_PresetSet = thisID;
end

function SpecMenuOptions_UpatePresetDB_OnClick()
	SpecMenuDB["EnchantPresets"][SpecMenuOptions_PresetSet] = SpecMenuOptions_PresetNameEdit:GetText();
	UIDropDownMenu_SetText(SpecMenuOptions_PresetMenu, SpecMenuDB["EnchantPresets"][SpecMenuOptions_PresetSet]);
end

function SpecMenuOptions_UpateDB_OnClick()
	SpecMenuDB["Specs"][SpMenuSpecNum][1] = SpecMenuOptions_NameEdit:GetText();
	SpecMenuDB["Specs"][SpMenuSpecNum][2] = SpecMenu_QuickswapNum1;
	SpecMenuDB["Specs"][SpMenuSpecNum][3] = SpecMenu_QuickswapNum2;
	UIDropDownMenu_SetText(SpecMenuOptions_Menu, SpecMenuDB["Specs"][SpMenuSpecNum][1]);
end

function SpecMenuOptions_QuickSwap1_Initialize()
	local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
		info = {
					text = SpecMenuDB["Specs"][k][1];
					func = SpecMenuOptions_QuickSwap1_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

function SpecMenuOptions_QuickSwap2_Initialize()
	local info;
	for k,v in pairs(SpecMenuDB["Specs"]) do
		info = {
			text = SpecMenuDB["Specs"][k][1];
			func = SpecMenuOptions_QuickSwap2_OnClick;
		};
			UIDropDownMenu_AddButton(info);
	end
end

function SpecMenuOptions_QuickSwap1_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap1, thisID);
	SpecMenuOptions_PresetNameEdit:SetText(SpecMenuDB["EnchantPresets"][thisID])
	SpecMenu_QuickswapNum1 = thisID;
end

function SpecMenuOptions_QuickSwap2_OnClick()
	local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptions_QuickSwap2, thisID);
	SpecMenu_QuickswapNum2 = thisID;
end

