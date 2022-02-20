function SpecMenu_OptionsPanelOnLoad(panel)
    panel.name="SpecMenu";
    InterfaceOptions_AddCategory(panel);
end

function SpecMenuOptions_Toggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide();
	else
		InterfaceOptionsFrame_OpenToCategory("SpecMenu");
	end
end

function SpecMenuOptions_Menu_Initialize()
    local info;
	for k,v in pairs(SpecMenuDB["Specs"][k]) do
				info = {
					text = SpecMenuDB["Specs"][k][1];
					func = SpecMenuOptions_Menu_OnClick;
				};
					UIDropDownMenu_AddButton(info);
	end
end

function SpecMenuOptions_Menu_OnClick()
    local thisID = this:GetID();
	UIDropDownMenu_SetSelectedID(SpecMenuOptionsFrame_Menu, thisID);
    SpecMenuOptionsSpecDrop_OnShow();
end

function SpecMenuOptionsSpecDrop_OnShow()
	SpecMenuOptions_Menu_Initialize();
end
function SpecMenuOptionsFrameOnShow()
end

