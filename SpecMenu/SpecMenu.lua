SpecMenu = LibStub("AceAddon-3.0"):NewAddon("SpecMenu", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0")
local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")
local addonName = ...
local specbutton, lastActiveSpec, mainframe;
local dewdrop = AceLibrary("Dewdrop-2.0");
local defIcon = "Interface\\Icons\\inv_misc_book_16"
local icon = LibStub('LibDBIcon-1.0');
local CYAN =  "|cff00ffff"
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
    { TableName = "HideMenu", false, Frame = "SpecMenuFrame", CheckBox = "SpecMenuOptions_HideMenu"},
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
            if db[v.TableName] then _G[v.Frame]:Hide() else _G[v.Frame]:Show() end
        end
    end
end

function SPM:GetPresetName(index)
    return MysticEnchantManagerUtil.GetPresetName(index)
end

function SPM:GetPresetIcon(index)
    return MysticEnchantManagerUtil.GetPresetIcon(index)
end

--returns current active spec
function SPM:GetSpecId()
    return SpecializationUtil.GetActiveSpecialization()
end

--returns current active enchant preset 
function SPM:GetPresetId()
    return MysticEnchantManagerUtil.GetActivePreset()
end

function SPM:GetSpecInfo(i)
    return SpecializationUtil.GetSpecializationInfo(i)
end

local function spellCheck(num,type)
    if num == SPM:GetSpecId() and type == "spec" or num == SPM:GetPresetId() and type == "enchant" then return true end
end

--loads the table of specs by checking if you know the spell for the spec that is associated with it
local function PopulateSpecDB()
    for i,v in ipairs(SPM.SpecInfo) do
        if CA_IsSpellKnown(v) and not SPM.db.Specs[i] then
            SPM.db.Specs[i] = { 1, 1}
        end
    end
end

--[[ checks to see if current spec is not last spec.
Done this way to stop it messing up last spec if you stop the cast mid way
 ]]
local function lastSpec(event, ...)
    local target, spell = ...
        if target == "player" and spell:match("Specialization") then
        local specNum = SPM.specNum
        if lastActiveSpec ~= specNum then
            SPM.db.LastSpec = lastActiveSpec;
        end
        local name, icon = SPM:GetSpecInfo(specNum)
        mainframe.icon:SetTexture(icon)
        minimap.icon = icon
        SPM:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        SPM:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
    end
end

local function SpecMenu_DewdropClick(specNum)
    if specNum ~= SPM:GetSpecId() then
        if IsMounted() then Dismount() end
        --used for the last spec favorite selection
        lastActiveSpec = SPM:GetSpecId();
        SPM.specNum = specNum
        SPM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", lastSpec);
        --ascension function for loading specs
        local spell = SpecializationUtil.GetSpecializationSpell(specNum)
        CastSpecialSpell(spell)
    else
        DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Spec is already active")
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
                'textHeight', 12,
                'textWidth', 12,
                'isTitle', true,
                'notCheckable', true
            )
            local function addSpec()
                for i,v in ipairs(SPM.SpecInfo) do
                    if CA_IsSpellKnown(v) then
                        local active = ""
                        local name, icon = SPM:GetSpecInfo(i)
                        if spellCheck(i,"spec") then active = " |cFF00FFFF(Active)" end
                        active = name..active
                        dewdrop:AddLine(
                                'text', active,
                                'icon', icon,
                                'textHeight', 12,
                                'textWidth', 12,
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
                    'textHeight', 12,
                    'textWidth', 12,
                    'func', SPM.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            dewdrop:AddLine(
				'text', "Options",
                'textHeight', 12,
                'textWidth', 12,
				'func', SPM.Options_Toggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
                'textHeight', 12,
                'textWidth', 12,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
end

local function SpecMenu_EnchantPreset_DewdropClick(presetID)
    if IsMounted() then Dismount() end
        --ascension function for changing enchant presets
            if presetID then
                if MysticEnchantManagerUtil.GetActivePreset() ~= presetID then
                    MysticEnchantManagerUtil.AttemptOperation("Activate", "CanActivate", presetID)
                else
                    DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Enchant Set is already active")
                end
            end
        dewdrop:Close();
end

--sets up the drop down menu for enchant presets
local function SpecMenu_EnchantPreset_DewdropRegister(self)
    dewdrop:Register(self,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            dewdrop:AddLine(
                'text', "|cffffff00Enchant Sets",
                'textHeight', 12,
                'textWidth', 12,
                'isTitle', true,
                'notCheckable', true
            )
            local function addPreset()
                for i = 1, C_MysticEnchantPreset.GetNumPresets() do
                    local active = ""
                    if spellCheck(i,"enchant") then active = " |cFF00FFFF(Active)" end
                    local text = SPM:GetPresetName(i)..active
                    local icon = SPM:GetPresetIcon(i)
                    dewdrop:AddLine(
                            'text', text,
                            'textHeight', 12,
                            'textWidth', 12,
                            'icon', icon,
                            'func', SpecMenu_EnchantPreset_DewdropClick,
                            'arg1', i
                    )
                end
            end
            addPreset()
            dewdrop:AddLine(
		    	'text', "Close Menu",
                'textHeight', 12,
                'textWidth', 12,
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

local function favorite_OnClick(arg1)
    local specNum;
    dewdrop:Close();
    if (arg1=="LeftButton") then
        if SPM.db.Specs[SPM:GetSpecId()][1] == "LastSpec" then
            specNum = SPM.db.LastSpec;
        else
            specNum =  SPM.db.Specs[SPM:GetSpecId()][1]
        end
    elseif (arg1=="RightButton") then
        if SPM.db.Specs[SPM:GetSpecId()][2] == "LastSpec" then
            specNum = SPM.db.LastSpec;
        else
        specNum =  SPM.db.Specs[SPM:GetSpecId()][2]
        end
    end
    if specNum ~= SPM:GetSpecId() then
        if IsMounted() then Dismount(); end
        lastActiveSpec = SPM:GetSpecId();
        SPM.specNum = specNum
        SPM:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", lastSpec);
        local spell = SpecializationUtil.GetSpecializationSpell(specNum)
        CastSpecialSpell(spell)
    else
        DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Spec is already active")
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
            SpecMenuFrame_Favorite:Show()
            SpecMenuFrame.icon:Show()
            SpecMenuFrame.Text:Show()
        else
            SpecMenuFrame_Menu:Hide()
            SpecMenuFrame_Favorite:Hide()
            SpecMenuFrame.icon:Hide()
            SpecMenuFrame.Text:Hide()
        end
    end
end

-- Used to show highlight as a frame mover
local unlocked = false
function SPM:UnlockFrame()
    if unlocked then
        SpecMenuFrame_Menu:Show()
        SpecMenuFrame_Favorite:Show()
        SpecMenuFrame.Highlight:Hide()
        unlocked = false
        GameTooltip:Hide()
    else
        SpecMenuFrame_Menu:Hide()
        SpecMenuFrame_Favorite:Hide()
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
    mainframe:Hide();
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

    local favoritebutton = CreateFrame("Button", "SpecMenuFrame_Favorite", SpecMenuFrame);
    favoritebutton:SetSize(70,34);
    favoritebutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -2);
    favoritebutton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
    favoritebutton:SetScript("OnClick", function(self, btnclick) favorite_OnClick(btnclick) end);
    favoritebutton.Highlight = favoritebutton:CreateTexture(nil, "OVERLAY");
    favoritebutton.Highlight:SetSize(70,34);
    favoritebutton.Highlight:SetPoint("CENTER", favoritebutton, 0, 0);
    favoritebutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected");
    favoritebutton.Highlight:Hide();
    favoritebutton:SetScript("OnEnter", function(self)
        if not dewdrop:IsOpen() then
            if not CA_IsSpellKnown(SPM.SpecInfo[1]) then return end
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:AddLine("Favorite Specs")
            local leftTxt, rightTxt
            if SPM.db.Specs[SPM:GetSpecId()][1] == "LastSpec" then
                leftTxt = "Last Spec"
            else
                leftTxt = SPM:GetSpecInfo(SPM.db.Specs[SPM:GetSpecId()][1])
            end
            if SPM.db.Specs[SPM:GetSpecId()][2] == "LastSpec" then
                rightTxt = "Last Spec"
            else
                rightTxt = SPM:GetSpecInfo(SPM.db.Specs[SPM:GetSpecId()][2])
            end
            GameTooltip:AddDoubleLine("|cffffffff"..leftTxt,"|cffffffff"..rightTxt)
            GameTooltip:Show()
        end
        toggleMainButton("show")
        favoritebutton.Highlight:Show();
    end)
    favoritebutton:SetScript("OnLeave", function()
        favoritebutton.Highlight:Hide();
        GameTooltip:Hide();
        toggleMainButton("hide")
    end);

InterfaceOptionsFrame:HookScript("OnShow", function()
    if InterfaceOptionsFrame and SpecMenuOptionsFrame:IsVisible() then
			SPM:OpenOptions();
    end
end)

function SPM:OnInitialize()
    if not SpecMenuDB then SpecMenuDB = {} end
    SPM.db = SpecMenuDB
    setupSettings(SPM.db)
    lastActiveSpec = SPM.db.LastSpec;
    SPM.optionsSpecNum = SPM:GetSpecId();
    SPM:RegisterEvent("ADDON_LOADED")

end

function SPM:ADDON_LOADED(event, arg1, arg2, arg3)
	-- setup for auction house window
	if event == "ADDON_LOADED" and arg1 == "Ascension_CharacterAdvancement" then
        CharacterAdvancementSideBarSpecListNineSlice:HookScript("OnHide", function()
            local name, icon = SPM:GetSpecInfo(SPM:GetSpecId())
            mainframe.icon:SetTexture(icon);
            minimap.icon = icon;
        end)
	end
end

-- toggle the main button frame
local function toggleMainFrame()
    if SpecMenuFrame:IsVisible() then
        SpecMenuFrame:Hide()
    else
        SpecMenuFrame:Show()
    end
end

--[[
SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
local function SlashCommand(msg)
    if msg == "reset" then
        SpecMenuDB = nil
        SPM:OnInitialize()
        DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
    elseif msg == "options" then
        SPM:Options_Toggle()
    else
        toggleMainFrame()
    end
end

function SPM:OnEnable()
    if icon then
        SPM.map = {hide = SPM.db.minimap}
        icon:Register('SpecMenu', minimap, SPM.map)
    end

    SPM.SpecInfo = SPEC_SWAP_SPELLS
    local name, icon = SPM:GetSpecInfo(SPM:GetSpecId())
    mainframe.icon:SetTexture(icon);
    minimap.icon = icon
    PopulateSpecDB()
    SPM:DropDownInitialize()
    toggleMainButton("hide")

    --Enable the use of /me or /mysticextended to open the loot browser
    SLASH_SPECMENU1 = "/specmenu";
    SLASH_SPECMENU2 = "/spm";
    SlashCmdList["SPECMENU"] = function(msg)
        SlashCommand(msg);
    end
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
    local specID, presetID, presetName, specName = SPM:GetSpecId(), SPM:GetPresetId()
    specName = "|cffffffff"..SPM:GetSpecInfo(specID)
    presetName = "|cffffffff"..SPM:GetPresetName(presetID)
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