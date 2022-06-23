local SpecMenu, SPM = ...
local addonName = "SpecMenu";
_G[addonName] = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local addon = _G[addonName];
local lastActiveSpec;
local nextSpec;
SpecMenu_Dewdrop = AceLibrary("Dewdrop-2.0");
SpecMenu_EnchantPreset_Dewdrop = AceLibrary("Dewdrop-2.0");
SpecMenu_OptionsMenu_Dewdrop = AceLibrary("Dewdrop-2.0");

--Set Savedvariables defaults
local DefaultSpecMenuDB  = {
	["Specs"] = {},
    ["EnchantPresets"] = {},
    ["LastSpec"] = {1,},
    ["EditAscenSpec"] = {},
    ["EditAscenPreset"] = {},
};

--returns current active spec
function SpecMenu_SpecId()
    return CA_GetActiveSpecId() +1
end

--returns current active enchant preset 
function SpecMenu_PresetId()
    return GetREPreset() +1
end

local function SpecChecked(specNum)
    if specNum == SpecMenu_SpecId() then return true end
end

local function PresetChecked(presetNum)
    if presetNum == SpecMenu_PresetId() then return true end
end

--loads the table of specs by checking if you know the spell for the spec that is associated with it
local function SpecMenu_PopulateSpecDB()
    for k,v in pairs(SpecMenu_SpecInfo) do
        if IsSpellKnown(v[1]) then
            if SpecMenuDB["Specs"] ~= nil and SpecMenuDB["Specs"][k] ~= nil then
                SpecName = SpecMenuDB["Specs"][k][1];
            else
                SpecName = "Specialization "..k;
                SpecMenuDB["Specs"][k] = {SpecName, 1, 1}
            end
        end
    end
end

--loads the table of enchant presets by checking if you know the spell for the preset that is associated with it
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

--[[ checks to see if current spec is not last spec.
Done this way to stop it messing up last spec if you stop the cast mid way
 ]]
local function SpecMenu_LastSpec()
    if lastActiveSpec ~= nextSpec then
        SpecMenuDB["LastSpec"] = lastActiveSpec;
    end
    addon:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
end

local function SpecMenu_DewdropClick(specSpell ,specNum)
    if specNum ~= SpecMenu_SpecId() then
        if IsMounted() then Dismount() end
        --used for the last spec quickswap selection
        lastActiveSpec = SpecMenu_SpecId();
        nextSpec = specNum;
        addon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", SpecMenu_LastSpec);
        --ascension function for loading specs
        CA_ActivateSpec(specNum);
    else
        print("Spec is already active")
    end
    SpecMenu_Dewdrop:Close();
end

--sets up the drop down menu for specs
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
        --ascension function for changing enchant presets
        RequestChangeRandomEnchantmentPreset(presetNum -1, true);
        SpecMenu_EnchantPreset_Dewdrop:Close();
end

--sets up the drop down menu for enchant presets
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

function SpecMenu_EnableMenu()
    if IsSpellKnown(SpecMenu_SpecInfo[1][1]) then
        return true;
    else
        return false;
    end
end

function SpecMenuQuickSwap_OnClick(arg1)
    local specNum;
    SpecMenu_Dewdrop:Close();
        if (arg1=="LeftButton") then
            if SpecMenuDB["Specs"][SpecMenu_SpecId()][2] == "LastSpec" then
                specNum = SpecMenuDB["LastSpec"];
            else
                specNum =  SpecMenuDB["Specs"][SpecMenu_SpecId()][2]
            end
        elseif (arg1=="RightButton") then
            if SpecMenuDB["Specs"][SpecMenu_SpecId()][3] == "LastSpec" then
                specNum = SpecMenuDB["LastSpec"];
            else
            specNum =  SpecMenuDB["Specs"][SpecMenu_SpecId()][3]
            end
        end
        if specNum ~= SpecMenu_SpecId() then
            if IsMounted() then Dismount(); end
            lastActiveSpec = SpecMenu_SpecId();
            nextSpec = specNum;
            addon:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", SpecMenu_LastSpec);
            CA_ActivateSpec(specNum);
        else
            print("Spec is already active")
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

local function CloneTable(t)				-- return a copy of the table t
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

local function SpecMenuFrame_OnLoad()
    if ( SpecMenuDB == nil ) then
        SpecMenuDB = CloneTable(DefaultSpecMenuDB);
    end
    SpecMenuOptions_CreateFrame();
    SpecMenuOptions_OpenOptions();
    lastActiveSpec = SpecMenuDB["LastSpec"];
    if SpecMenu_EnableMenu() then
    SpecMenuFrame_QuickSwap:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_TOP")
		if SpecMenuDB["Specs"][SpecMenu_SpecId()][2] == "LastSpec" then
            GameTooltip:AddLine("Last Spec")
        else
            GameTooltip:AddLine(SpecMenuDB["Specs"][SpecMenuDB["Specs"][SpecMenu_SpecId()][2]][1])
        end
        if SpecMenuDB["Specs"][SpecMenu_SpecId()][3] == "LastSpec" then
            GameTooltip:AddLine("Last Spec")
        else
            GameTooltip:AddLine(SpecMenuDB["Specs"][SpecMenuDB["Specs"][SpecMenu_SpecId()][3]][1])
        end
		GameTooltip:Show()
	end)
    SpecMenuFrame_QuickSwap:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
end

--Creates the main interface
local function SpecMenu_CreateFrame()
	local mainframe = CreateFrame("FRAME", "SpecMenuFrame", UIParent, nil);
    mainframe:SetPoint("CENTER",0,0);
    mainframe:SetSize(120,90);
    mainframe:EnableMouse(true);
    mainframe:SetMovable(true);
    mainframe:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = "true",
        insets = {left = "11", right = "12", top = "12", bottom = "11"},
        edgeSize = 32,
        titleSize = 32,
    });
    mainframe:RegisterForDrag("LeftButton");
    mainframe:SetScript("OnDragStart", function(self) SpecMenuFrame_OnClick_MoveFrame() end)
    mainframe:SetScript("OnDragStop", function(self) SpecMenuFrame_OnClick_StopMoveFrame() end)
    mainframe:RegisterEvent("ADDON_LOADED")
    mainframe:SetScript("OnEvent", function(self, event, addonName)
        if addonName ~= "SpecMenu" then
            return
        else
            SpecMenuFrame_OnLoad();
        end
        self:UnregisterEvent("ADDON_LOADED");
        self:SetScript("OnEvent", nil);
    end);
	local specbutton = CreateFrame("Button", "SpecMenuFrame_Menu", SpecMenuFrame, "OptionsButtonTemplate");
    specbutton:SetSize(100,30);
    specbutton:SetPoint("BOTTOM", SpecMenuFrame, "BOTTOM", 0, 14);
    specbutton:SetText("Spec|Enchant");
    specbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    specbutton:SetScript("OnClick", function(self, btnclick, down) SpecMenu_OnClick(btnclick) end);

    local quickswapbutton = CreateFrame("Button", "SpecMenuFrame_QuickSwap", SpecMenuFrame, "OptionsButtonTemplate");
    quickswapbutton:SetSize(100,30);
    quickswapbutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -14);
    quickswapbutton:SetText("QuickSwap");
    quickswapbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    quickswapbutton:SetScript("OnClick", function(self, btnclick, down) SpecMenuQuickSwap_OnClick(btnclick) end);
end
SpecMenu_CreateFrame();
