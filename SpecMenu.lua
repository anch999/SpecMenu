local SpecMenu, SPM = ...
local addonName = "SpecMenu"
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addon = _G[addonName] 
SpecMenu_Dewdrop = AceLibrary("Dewdrop-2.0");
SpecMenu_EnchantPreset_Dewdrop = AceLibrary("Dewdrop-2.0");
SpecMenu_OptionsMenu_Dewdrop = AceLibrary("Dewdrop-2.0");

local DefaultSpecMenuDB  = {
	["Specs"] = {},
    ["EnchantPresets"] = {},
    ["ActiveSpec"] = {1, 1},
};

local function SpecMenu_PopulateSpecDB()
    
    for k,v in pairs(SpecMenu_SpecInfo) do
        if IsSpellKnown(v[1]) then
            if SpecMenuDB["Specs"] ~= nil and SpecMenuDB["Specs"][k] ~= nil then
                SpecName = SpecMenuDB["Specs"][k][1];
            else
                SpecName = "Specialization "..k;
                SpecMenuDB["Specs"][k] = {SpecName, 1, 2}
            end
        end
    end
end


local function SpecMenu_PopulatePresetDB()

    for k,v in pairs(SpecMenu_PresetSpellIDs) do
        if IsSpellKnown(v) then
            if SpecMenuDB["EnchantPresets"] ~= nil and SpecMenuDB["EnchantPresets"][k] ~= nil then
                PresetName = SpecMenuDB["EnchantPresets"][k];
            else
                PresetName = "Enchant Preset "..k;
                SpecMenuDB["EnchantPresets"][k] = PresetName;
            end
        end
    end
end


local function SpecMenu_DewdropClick(specSpell ,specNum)
    if specNum ~= SpecMenuDB["ActiveSpec"][1] then
        if IsMounted() then Dismount() end
        CA_ActivateSpec(specNum);
    else
        print("Spec is already active")
    end
    SpecMenu_Dewdrop:Close();
    SpecMenu_currentspecNum = specNum;
    if InterfaceOptionsFrame:IsVisible() then
        SpecMenuOptions_OpenOptions();
	end
end

local function SpecMenu_DewdropRegister()
    SpecMenu_PopulateSpecDB();
    SpecMenu_Dewdrop:Register(SpecMenuFrame_Menu,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
                for k,v in pairs(SpecMenu_SpecInfo) do     
                    if IsSpellKnown(v[1]) then
                        SpecMenu_Dewdrop:AddLine(
                                'text', SpecMenuDB["Specs"][k][1],
                                'checked', SpecChecked(k),
                                'func', SpecMenu_DewdropClick,
                                'arg1', v[1],
                                'arg2', v[2]
                        )
                    end
                end
                SpecMenu_Dewdrop:AddLine(
					'text', "Close Menu",
                    'textR', 0,
                    'textG', 1,
                    'textB', 1,
					'func', function() SpecMenu_Dewdrop:Close() end,
					'notCheckable', true
				)
		end,
		'dontHook', true
	)
end

local function SpecMenu_EnchantPreset_DewdropClick(presetNum)
        if IsMounted() then Dismount() end
    RequestChangeRandomEnchantmentPreset(presetNum -1, true);
    SpecMenu_EnchantPreset_Dewdrop:Close();
    if InterfaceOptionsFrame:IsVisible() then
        SpecMenuOptions_OpenOptions();
	end
end

function SpecChecked(k)
    if k == SpecMenuDB["ActiveSpec"][1] then return true end
end

function PresetChecked(k)
    if k == (GetREPreset() +1) then return true end
end

local function SpecMenu_EnchantPreset_DewdropRegister()    
    SpecMenu_PopulatePresetDB();
    SpecMenu_EnchantPreset_Dewdrop:Register(SpecMenuFrame_Menu,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
                for k,v in pairs(SpecMenu_PresetSpellIDs) do
                    if IsSpellKnown(v) then
                        SpecMenu_EnchantPreset_Dewdrop:AddLine(
                                'checked', PresetChecked(k),
                                'text', SpecMenuDB["EnchantPresets"][k],
                                'func', SpecMenu_EnchantPreset_DewdropClick,
                                'arg1', k
                    )
                    end
                end
                SpecMenu_EnchantPreset_Dewdrop:AddLine(
					'text', "Close Menu",
                    'textR', 0,
                    'textG', 1,
                    'textB', 1,
					'func', function() SpecMenu_EnchantPreset_Dewdrop:Close() end,
					'notCheckable', true
				)
		end,
		'dontHook', true
	)
end

function SpecMenuQuickSwap_OnClick()
    SpecMenu_Dewdrop:Close();
        if (arg1=="LeftButton") then
            SpecMenu_currentspecNum =  SpecMenuDB["Specs"][SpecMenuDB["ActiveSpec"][1]][2]
        elseif (arg1=="RightButton") then
            SpecMenu_currentspecNum =  SpecMenuDB["Specs"][SpecMenuDB["ActiveSpec"][1]][3]
        end

        if SpecMenu_currentspecNum ~= SpecMenuDB["ActiveSpec"][1] then
            if IsMounted() then Dismount(); end
                CA_ActivateSpec(SpecMenu_currentspecNum);
        else
            print("Spec is already active")
        end
end

function SpecMenuSetCurrent(event, unit, spellName, spellRank)
    if spellName:find("Specialization") then
        for k,v in pairs(SpecMenu_SpecInfo) do
            if spellName:find(SpecMenu_SpecInfo[k][3]) then
                SpecMenu_currentspecNum = SpecMenu_SpecInfo[k][2];
                SpecMenuDB["ActiveSpec"][1] = SpecMenu_currentspecNum;
            end
        end
    end
    if InterfaceOptionsFrame:IsVisible() then
        SpecMenuOptions_OpenOptions();
	end
end

function SpecMenu_OnClick(arg1)
    if SpecMenu_OptionsMenu_Dewdrop:IsOpen() or SpecMenu_EnchantPreset_Dewdrop:IsOpen() or SpecMenu_Dewdrop:IsOpen() then
        SpecMenu_OptionsMenu_Dewdrop:Close();
        SpecMenu_EnchantPreset_Dewdrop:Close();
        SpecMenu_Dewdrop:Close();
    else
        if (arg1=="LeftButton") then
            SpecMenu_DewdropRegister();
            SpecMenu_Dewdrop:Open(this);
        elseif (arg1=="RightButton") then
            if IsAltKeyDown() then
                SpecMenuOptionsCreateFrame_Initialize();
                SpecMenuOptions_OpenOptions();
                SpecMenuOptions_Toggle();
            else
                SpecMenu_EnchantPreset_DewdropRegister()
                SpecMenu_EnchantPreset_Dewdrop:Open(this);
            end
        end
    end
end

function SpecMenuFrame_OnClickHIDE()
    if SPM.FrameClosed then
        SpecMenuFrame:Show();
        SPM.FrameClosed = false
    else
        SpecMenuFrame:Hide();
        SPM.FrameClosed = true
    end
end

function SpecMenuFrame_OnClickLOCK()
    if SPM.FrameLocked then
        SPM.FrameLocked = false;
    else
        SPM.FrameLocked = true;
    end
    SpecMenu_OptionsMenu_Dewdrop:Close()
end

function SpecMenuFrame_OnClick_MoveFrame()
    if SPM.FrameLocked then
        return
    end
    SpecMenuFrame:StartMoving();
    SpecMenuFrame.isMoving = true;
end

function SpecMenuFrame_OnClick_StopMoveFrame()
    if SPM.FrameLocked then
        return
    end
    this:StopMovingOrSizing();
    this.isMoving = false;
end

function SpecMenuFrame_OnEvent()
    if ( SpecMenuDB == nil ) then
        SpecMenuDB = CloneTable(DefaultSpecMenuDB);
    end
end

function CloneTable(t)				-- return a copy of the table t
	local new = {};					-- create a new table
	local i, v = next(t, nil);		-- i is an index of t, v = t[i]
	while i do
		if type(v)=="table" then 
			v=CloneTable(v);
		end 
		new[i] = v;
		i, v = next(t, i);			-- get next index
	end
	return new;
end

function SpecMenuFrame_OnLoad()
    this:RegisterForDrag("LeftButton");
    SpecMenuFrame_Menu:SetText("Spec|Enchant");
    SpecMenuFrame_QuickSwap:SetText("QuickSwap");
    addon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", SpecMenuSetCurrent);

end

function TooltipLoad()
    GameTooltip:SetOwner(SpecMenuFrame_QuickSwap, "ANCHOR_RIGHT");
	GameTooltip:SetGuildBankItem(GetCurrentGuildBankTab(), self:GetID());
end