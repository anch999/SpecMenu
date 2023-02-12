SpecMenu = LibStub("AceAddon-3.0"):NewAddon("SpecMenu", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")
local addonName = ...
local specbutton, lastActiveSpec, mainframe;
local dewdrop = AceLibrary("Dewdrop-2.0");
local defIcon = "Interface\\Icons\\inv_misc_book_16"
local icon = LibStub('LibDBIcon-1.0');
local 
SPECMENU_MINIMAP = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
    type = 'data source',
    text = "SpecMenu",
    icon = defIcon,
  })
local minimap = SPECMENU_MINIMAP

--Set Savedvariables defaults
local DefaultSettings  = {
    { TableName = "Specs", {} },
    { TableName = "EnchantPresets", {} },
    { TableName = "LastSpec", 1 },
    { TableName = "ShowMenuOnHover", false, Frame = "SpecMenuFrame",CheckBox = "SpecMenuOptions_ShowOnHover" },
    { TableName = "HideMenu", false, CheckBox = "SpecMenuOptions_HideMenu"},
    { TableName = "minimap", false, CheckBox = "SpecMenuOptions_HideMinimap"},
};

--[[ TableName = Name of the saved setting
CheckBox = Global name of the checkbox if it has one and first numbered table entry is the boolean
Text = Global name of where the text and first numbered table entry is the default text 
Frame = Frame or button etc you want hidden/shown at start based on condition ]]
local function setupSettings(db)
    for _,v in ipairs(DefaultSettings) do
        if db[v.TableName] == nil then
            if #v > 1 then
                db[v.TableName] = {}
                for _, n in ipairs(v) do
                    tinsert(db[v.TableName], n)
                end
            else
                db[v.TableName] = v[1]
            end
        end

        if v.CheckBox then
            _G[v.CheckBox]:SetChecked(db[v.TableName])
        end
        if v.Text then
            _G[v.Text]:SetText(db[v.TableName])
        end
        if v.Frame then
            _G[v.Frame]:Show(db[v.TableName])
        end
    end
end
--returns current active spec
function SPM:SpecId()
    return CA_GetActiveSpecId() +1
end

--returns current active enchant preset 
function SPM:PresetId()
    return GetREPreset() +1
end

local function spellCheck(num,type)
    if num == SPM:SpecId() and type == "spec" or num == SPM:PresetId() and type == "enchant" then return true end
end

--loads the table of specs by checking if you know the spell for the spec that is associated with it
local function PopulateSpecDB()
    for i,v in ipairs(SPM.SpecInfo) do
        if IsSpellKnown(v) and not SPM.db.Specs[i] then
            SPM.db.Specs[i] = { 1, 1}
        end
    end
end

--loads the table of enchant presets by checking if you know the spell for the preset that is associated with it
local function populatePresetDB()
    for i,v in ipairs(SPM.PresetSpellIDs) do
        if IsSpellKnown(v) and not SPM.db.EnchantPresets[i] then
            SPM.db.EnchantPresets[i] = true;
        end
    end
end

local function changeEnchantSet(specNum)
    if SPM.db.Specs[specNum][3] then
        RequestChangeRandomEnchantmentPreset(SPM.db.Specs[specNum][3] -2, true);
    end
end

--[[ checks to see if current spec is not last spec.
Done this way to stop it messing up last spec if you stop the cast mid way
 ]]
local function lastSpec(specNum)
    if lastActiveSpec ~= specNum then
        SPM.db.LastSpec = lastActiveSpec;
    end
    mainframe.icon:SetTexture(SPM.specIcon[specNum] or defIcon);
    minimap.icon = SPM.specIcon[specNum] or defIcon;
    SPM:ScheduleTimer(changeEnchantSet, .5, specNum);
    SPM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    SPM:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
end

local function castInterrupted()
    SPM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    SPM:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
end

local function SpecMenu_DewdropClick(specNum)
    if specNum ~= SPM:SpecId() then
        if IsMounted() then Dismount() end
        --used for the last spec quickswap selection
        lastActiveSpec = SPM:SpecId();
        SPM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", lastSpec, specNum);
        SPM:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", castInterrupted);
        --ascension function for loading specs
        CA_ActivateSpec(specNum);
    else
        DEFAULT_CHAT_FRAME:AddMessage("Spec is already active")
    end
    dewdrop:Close();
end

--sets up the drop down menu for specs
local function SpecMenu_DewdropRegister(self, frame)
    PopulateSpecDB();
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Specializations",
                'isTitle', true,
                'notCheckable', true
            )
            local function addSpec()
                for i,v in ipairs(SPM.SpecInfo) do
                    if IsSpellKnown(v) then
                        local active = ""
                        if spellCheck(i,"spec") then active = " |cFF00FFFF(Active)" end 
                        if SPM.specName[i] then
                            active = SPM.specName[i]..active
                        else
                            active = "Specialization "..i..active
                        end
                        dewdrop:AddLine(
                                'text', active,
                                'icon', SPM.specIcon[i] or defIcon,
                                'func', SpecMenu_DewdropClick,
                                'arg1', i
                        )
                    else
                        return
                    end
                end
            end
            addSpec()
            dewdrop:AddLine()
            if frame == "SpecMenuFrame_Menu" then
                dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'func', SPM.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
				'func', SPM.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
				'closeWhenClicked', true,
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
        dewdrop:Close();
end

--sets up the drop down menu for enchant presets
local function SpecMenu_EnchantPreset_DewdropRegister(self)
    populatePresetDB();
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Enchant Sets",
                'isTitle', true,
                'notCheckable', true
            )
            local function addPreset()
                for i,v in ipairs(SPM.PresetSpellIDs) do
                    if IsSpellKnown(v) then
                        local active = ""
                        local icon = defIcon
                        if spellCheck(i,"enchant") then active = " |cFF00FFFF(Active)" end
                        local text = "Enchants Set "..i..active
                        if SPM.enchantSetsDB[i] then
                            if SPM.enchantSetsDB[i].name then text = SPM.enchantSetsDB[i].name..active end
                            if SPM.enchantSetsDB[i].icon then icon = SPM.enchantSetsDB[i].icon end
                        end
                        dewdrop:AddLine(
                                'text', text,
                                'icon', icon,
                                'func', SpecMenu_EnchantPreset_DewdropClick,
                                'arg1', i
                        )
                    else
                        return
                    end
                end
            end
            addPreset()
            dewdrop:AddLine(
		    	'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
				'closeWhenClicked', true,
				'notCheckable', true
		    )
		end,
		'dontHook', true
	)
end

local function quickSwap_OnClick(arg1)
    local specNum;
    dewdrop:Close();
    if (arg1=="LeftButton") then
        if SPM.db.Specs[SPM:SpecId()][1] == "LastSpec" then
            specNum = SPM.db.LastSpec;
        else
            specNum =  SPM.db.Specs[SPM:SpecId()][1]
        end
    elseif (arg1=="RightButton") then
        if SPM.db.Specs[SPM:SpecId()][2] == "LastSpec" then
            specNum = SPM.db.LastSpec;
        else
        specNum =  SPM.db.Specs[SPM:SpecId()][2]
        end
    end
    if specNum ~= SPM:SpecId() then
        if IsMounted() then Dismount(); end
        lastActiveSpec = SPM:SpecId();
        SPM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", lastSpec, specNum);
        SPM:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", castInterrupted);
        CA_ActivateSpec(specNum);
    else
        DEFAULT_CHAT_FRAME:AddMessage("Spec is already active")
    end
end

local function mainButton_OnClick(self, arg1)
    if dewdrop:IsOpen() then SPM:OnEnter(self) dewdrop:Close() return end
    GameTooltip:Hide()
    if (arg1=="LeftButton") then
        SpecMenu_DewdropRegister(self, "SpecMenuFrame_Menu");
        dewdrop:Open(self);
    elseif (arg1=="RightButton") then
        SpecMenu_EnchantPreset_DewdropRegister(self);
        dewdrop:Open(self);
    end
end

local function toggleMainButton(toggle)
    if SPM.db.ShowMenuOnHover then
        if toggle == "show" then
            SpecMenuFrame_Menu:Show()
            SpecMenuFrame_QuickSwap:Show()
            SpecMenuFrame.icon:Show()
            SpecMenuFrame.Text:Show()
        else
            SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_QuickSwap:Hide()
            SpecMenuFrame.icon:Hide()
            SpecMenuFrame.Text:Hide()
        end
    end
end

local unlocked = false
function SPM:UnlockFrame()
    if unlocked then
        SpecMenuFrame_Menu:Show()
        SpecMenuFrame_QuickSwap:Show()
        SpecMenuFrame.Highlight:Hide()
        unlocked = false
        GameTooltip:Hide()
    else
        SpecMenuFrame_Menu:Hide()
        SpecMenuFrame_QuickSwap:Hide()
        SpecMenuFrame.Highlight:Show()
        unlocked = true
    end
end

--Creates the main interface
	mainframe = CreateFrame("Button", "SpecMenuFrame", UIParent, nil);
    mainframe:SetSize(70,70);
    mainframe:EnableMouse(true);
    mainframe:RegisterForDrag("LeftButton");
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end);
    mainframe:SetScript("OnDragStop", function(self) mainframe:StopMovingOrSizing() end);
    mainframe:SetMovable(true)
    mainframe:RegisterForClicks("RightButtonDown");
    mainframe:SetScript("OnClick", function(self, btnclick) if unlocked then SPM:UnlockFrame() end end);
    mainframe.icon = mainframe:CreateTexture(nil, "ARTWORK");
    mainframe.icon:SetSize(55,55);
    mainframe.icon:SetPoint("CENTER", mainframe,"CENTER",0,0);
    mainframe.Text = mainframe:CreateFontString();
    mainframe.Text:SetFont("Fonts\\FRIZQT__.TTF", 13);
    mainframe.Text:SetFontObject(GameFontNormal);
    mainframe.Text:SetText("|cffffffffSpec\nMenu");
    mainframe.Text:SetPoint("CENTER", mainframe.icon, "CENTER", 0, 0);
    mainframe.Highlight = mainframe:CreateTexture(nil, "OVERLAY");
    mainframe.Highlight:SetSize(70,70);
    mainframe.Highlight:SetPoint("CENTER", mainframe, 0, 0);
    mainframe.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected");
    mainframe.Highlight:Hide();
    mainframe:Show();
    mainframe:SetScript("OnEnter", function(self) 
        if unlocked then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            toggleMainButton("show")
        end
    end)
    mainframe:SetScript("OnLeave", function() GameTooltip:Hide() end)

	specbutton = CreateFrame("Button", "SpecMenuFrame_Menu", SpecMenuFrame);
    specbutton:SetSize(70,34);
    specbutton:SetPoint("BOTTOM", SpecMenuFrame, "BOTTOM", 0, 2);
    specbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    specbutton:SetScript("OnClick", function(self, btnclick) mainButton_OnClick(self, btnclick) end);
    specbutton.Highlight = specbutton:CreateTexture(nil, "OVERLAY");
    specbutton.Highlight:SetSize(70,34);
    specbutton.Highlight:SetPoint("CENTER", specbutton, 0, 0);
    specbutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected");
    specbutton.Highlight:Hide();
    specbutton:SetScript("OnEnter", function(self)
        if not dewdrop:IsOpen() then
        SPM:OnEnter(self)
        end
        specbutton.Highlight:Show();
        toggleMainButton("show")
    end)
    specbutton:SetScript("OnLeave", function()
        specbutton.Highlight:Hide();
        GameTooltip:Hide();
        toggleMainButton("hide")
    end);

    local quickswapbutton = CreateFrame("Button", "SpecMenuFrame_QuickSwap", SpecMenuFrame);
    quickswapbutton:SetSize(70,34);
    quickswapbutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -2);
    quickswapbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    quickswapbutton:SetScript("OnClick", function(self, btnclick) quickSwap_OnClick(btnclick) end);
    quickswapbutton.Highlight = quickswapbutton:CreateTexture(nil, "OVERLAY");
    quickswapbutton.Highlight:SetSize(70,34);
    quickswapbutton.Highlight:SetPoint("CENTER", quickswapbutton, 0, 0);
    quickswapbutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected");
    quickswapbutton.Highlight:Hide();
    quickswapbutton:SetScript("OnEnter", function(self)
        if not dewdrop:IsOpen() then
            if not IsSpellKnown(SPM.SpecInfo[1]) then return end
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Quick Specs")
            local leftTxt, rightTxt
            if SPM.db.Specs[SPM:SpecId()][1] == "LastSpec" then
                leftTxt = "Last Spec"
            else
                leftTxt = SPM.specName[SPM.db.Specs[SPM:SpecId()][1]] or ("Specialization "..SPM.db.Specs[SPM:SpecId()][1])
            end
            if SPM.db.Specs[SPM:SpecId()][2] == "LastSpec" then
                rightTxt = "Last Spec"
            else
                rightTxt = SPM.specName[SPM.db.Specs[SPM:SpecId()][2]] or ("Specialization "..SPM.db.Specs[SPM:SpecId()][2])
            end
            GameTooltip:AddDoubleLine("|cffffffff"..leftTxt,"|cffffffff"..rightTxt)
            GameTooltip:Show()
        end
        toggleMainButton("show")
        quickswapbutton.Highlight:Show();
    end)
    quickswapbutton:SetScript("OnLeave", function()
        quickswapbutton.Highlight:Hide();
        GameTooltip:Hide();
        toggleMainButton("hide")
    end);

InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and SpecMenuOptionsFrame:IsVisible() then
			SpecMenuOptions_OpenOptions();
    end
end)

function SPM:OnInitialize()
    if not SpecMenuDB then SpecMenuDB = {} end
    SPM.db = SpecMenuDB
    setupSettings(SPM.db)
    lastActiveSpec = SPM.db.LastSpec;
    SPM.optionsSpecNum = SPM:SpecId();
    SPM.OptionsLoaded = false;
end


function SPM:OnEnable()
    if icon then
        SPM.map = {hide = SPM.db.minimap}
        icon:Register('SpecMenu', minimap, SPM.map)
    end

    SPM.enchantSetsDB = AscensionUI_CDB.EnchantManager.presets
    SPM.specName = AscensionUI_CDB.CA2.SpecNamesCustom
    SPM.specIcon = AscensionUI_CDB.CA2.SpecIconsCustom
    SPM.SpecInfo = SPEC_SWAP_SPELLS
    SPM.PresetSpellIDs = PRESET_CHANGE_SPELLS
    mainframe.icon:SetTexture(SPM.specIcon[SPM:SpecId()] or defIcon);
    minimap.icon = SPM.specIcon[SPM:SpecId()] or defIcon
    populatePresetDB()
    PopulateSpecDB()
    CA2.Scroll_SpecList.PopupController.frame:HookScript("OnHide", function()
        mainframe.icon:SetTexture(SPM.specIcon[SPM:SpecId()] or defIcon);
        minimap.icon = SPM.specIcon[SPM:SpecId()] or defIcon;
    end)
    SPM:DropDownInitialize()
    toggleMainButton("hide")
end

local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if button == "LeftButton" then
        if dewdrop:IsOpen() then dewdrop:Close() return end
        SpecMenu_DewdropRegister(self);
        dewdrop:Open(self);
    elseif button == "RightButton" then
        if dewdrop:IsOpen() then dewdrop:Close() return end
        SpecMenu_EnchantPreset_DewdropRegister(self);
        dewdrop:Open(self);
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function SPM:OnEnter(self)
    GameTooltip:SetOwner(self, 'ANCHOR_NONE')
    GameTooltip:SetPoint(GetTipAnchor(self))
    GameTooltip:ClearLines()
    local specID, presetID, presetName, specName = SPM:SpecId(), SPM:PresetId()
    if SPM.specName[specID] then
        specName = "|cffffffff"..SPM.specName[specID]
    else
        specName = "|cffffffffSpecialization "..specID
    end
    if SPM.enchantSetsDB[presetID] and SPM.enchantSetsDB[presetID].name then
        presetName = "|cffffffff"..SPM.enchantSetsDB[presetID].name
    else
        presetName = "|cffffffffEnchants Set "..presetID
    end
    GameTooltip:AddLine("SpecMenu")
    GameTooltip:AddDoubleLine("Active Spec:", specName)
    GameTooltip:AddDoubleLine("Active Preset:", presetName)
    GameTooltip:Show()
end

function minimap.OnEnter(self)
    SPM:OnEnter(self)
end

function SPM:ToggleMinimap()
    local hide = not SPM.db.minimap
    SPM.db.minimap = hide
    if hide then
      icon:Hide('SpecMenu')
    else
      icon:Show('SpecMenu')
    end
end