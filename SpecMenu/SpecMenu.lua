local SPM = LibStub("AceAddon-3.0"):NewAddon("SpecMenu", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceComm-3.0", "AceSerializer-3.0", "SettingsCreator-1.0")
SPECMENU = SPM
SPM.dewdrop = AceLibrary("Dewdrop-2.0")
local CYAN =  "|cff00ffff"
local WHITE = "|cffFFFFFF"
local LIMEGREEN = "|cFF32CD32"

--Set Savedvariables defaults
local DefaultSettings  = {
    Specs = {},
    LastSpec = 1,
    ShowMenuOnHover = false,
    HideMenu = false,
    minimap = false,
    autoMenu = false,
    txtSize = 12,
    enchantSpecs = {},
    SpecDisplayScale = 1,
}

function SPM:OnInitialize()
    self.db = self:SetupDB("SpecMenuDB", DefaultSettings)
    self.lastActiveSpec = self.db.LastSpec
    self:RegisterEvent("ADDON_LOADED")
end

function SPM:OnEnable()
    self.SpecInfo = SPEC_SWAP_SPELLS
    local name, icon = self:GetSpecInfo(self:GetSpecId())
    self.optionsSpecNum = self:GetSpecId()
    self.class = select(2,UnitClass("player"))
    self:InitializeMinimap()
    self:SetMapIcon(icon)
    self:CreateMainUI(icon)
    self:PopulateSpecDB()
    self:CreateOptionsUI()
    self:CreateSpecDisplay()
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED")
    self:SlashCommandInitialize()
end

function SPM:UNIT_SPELLCAST_SUCCEEDED(event, ...)
    self:LastSpec(event, ...)
end

function SPM:ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED(event, ...)
    self:LastSpec(event, ...)
end

--[[ checks to see if current spec is not last spec.
Done this way to stop it messing up last spec if you stop the cast mid way
 ]]
function SPM:LastSpec(event, ...)
    local target, spell = ...
        if event == "ASCENSION_CA_SPECIALIZATION_ACTIVE_ID_CHANGED" or (event == "UNIT_SPELLCAST_SUCCEEDED" and target == "player" and  spell == "Activate Mystic Enchant Preset") then
            local specNum = SPM.specNum
            if not specNum then
                return
            end
            if SPM.lastActiveSpec ~= specNum then
                SPM.db.LastSpec = SPM.lastActiveSpec
            end
            local name, icon = SPM:GetSpecInfo(specNum)
            SpecMenuFrame.icon:SetTexture(icon)
            SPM:SetMapIcon(icon)
            Timer.After(0.5, SPM.SetDisplayText)
        end
end

function SPM:DewdropClick(specNum)
    local currentSpecID = self:GetSpecId()
    if specNum ~= currentSpecID then
        if IsMounted() then Dismount() end
        --used for the last spec favorite selection
        self.lastActiveSpec = currentSpecID
        self.specNum = specNum
        --ascension function for loading specs
        local spell = SpecializationUtil.GetSpecializationSpell(specNum)
        CastSpecialSpell(spell)
    else
        DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Spec is already active")
    end
    self.dewdrop:Close()
end

local hookWorldFrame
--sets up the drop down menu for specs
function SPM:DewdropRegister(button, showUnlock)
    if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
    self:PopulateSpecDB()
    self.dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            self.dewdrop:AddLine(
                'text', "|cffffff00Specializations",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
                'isTitle', true,
                'notCheckable', true
            )
            local function addSpec()
                local specList = {}
                for i,v in ipairs(self.SpecInfo) do
                    if CA_IsSpellKnown(v) then
                        specList[self.db.Specs[i].num] = i
                    else
                        break
                    end
                end
                for _, i in ipairs(specList) do
                    local name, icon = self:GetSpecInfo(i)
                    name = self:SpellCheck(i,"spec") and name.." |cFF00FFFF(Active)" or name
                    if self.reorderMenu then
                        self:ChangeEntryOrder(name, icon, self.db.Specs[i].num, self.db.Specs)
                    else
                        self.dewdrop:AddLine(
                            'text', name,
                            'icon', icon,
                            'textHeight', self.db.txtSize,
                            'textWidth', self.db.txtSize,
                            'func', function() SPM:DewdropClick(i) end
                        )
                    end
                end
            end
            addSpec()
            self:AddDividerLine(35)
            local text = self.reorderMenu and LIMEGREEN.."Reorder" or "Reorder"
            self.dewdrop:AddLine(
                    'text', text,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', function() self.reorderMenu = not self.reorderMenu end,
                    'notCheckable', true,
                    'tooltipText', "Left click to move up\nRight click to move down"
                )
            if showUnlock then
                self.dewdrop:AddLine(
                    'text', "Unlock Frame",
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', self.UnlockFrame,
                    'notCheckable', true,
                    'closeWhenClicked', true
                )
            end
            self.dewdrop:AddLine(
				'text', "Options",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'func', self.OptionsToggle,
				'notCheckable', true,
                'closeWhenClicked', true
			)
            self.dewdrop:AddLine(
				'text', "Close Menu",
                'textR', 0,
                'textG', 1,
                'textB', 1,
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
				'closeWhenClicked', true,
				'notCheckable', true
			)
		end,
		'dontHook', true
	)
    self.dewdrop:Open(button)

    if not hookWorldFrame then
        WorldFrame:HookScript("OnEnter", function()
            if self.dewdrop:IsOpen() then
                self.dewdrop:Close()
            end
        end)
        hookWorldFrame = true
    end
end

function SPM:EnchantSpecClick(presetID)
    if IsMounted() then Dismount() end
        --ascension function for changing enchant presets
            if presetID then
                if MysticEnchantManagerUtil.GetActivePreset() ~= presetID then
                    MysticEnchantManagerUtil.AttemptOperation("Activate", "CanActivate", presetID)
                else
                    DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Enchant Set is already active")
                end
            end
        self.dewdrop:Close()
end

--sets up the drop down menu for enchant presets
function SPM:EnchantPreset_DewdropRegister(button)
    if self.dewdrop:IsOpen(button) then self.dewdrop:Close() return end
    self.dewdrop:Register(button,
        'point', function(parent)
            return "TOP", "BOTTOM"
        end,
        'children', function(level, value)
            self.dewdrop:AddLine(
                'text', "|cffffff00Enchant Sets",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
                'isTitle', true,
                'notCheckable', true
            )
            local function addPreset()
                local enchantSpecs = {}
                for i = 1, C_MysticEnchantPreset.GetNumPresets() do
                    self.db.enchantSpecs[i] = self.db.enchantSpecs[i] or { num = i }
                    enchantSpecs[self.db.enchantSpecs[i].num] = i
                end
                for _, i in ipairs(enchantSpecs) do
                    local name = self:GetPresetName(i)
                    name = self:SpellCheck(i,"enchant") and name.." |cFF00FFFF(Active)" or name
                    local icon = self:GetPresetIcon(i)
                    if self.reorderEnchantMenu then
                        self:ChangeEntryOrder(name, icon, self.db.enchantSpecs[i].num, self.db.enchantSpecs)
                    else
                        self.dewdrop:AddLine(
                                'text', name,
                                'textHeight', self.db.txtSize,
                                'textWidth', self.db.txtSize,
                                'icon', icon,
                                'func', function() SPM:EnchantSpecClick(i) end
                        )
                    end
                end
            end
            addPreset()
            self:AddDividerLine(35)
            local text = self.reorderEnchantMenu and LIMEGREEN.."Reorder" or "Reorder"
            self.dewdrop:AddLine(
                    'text', text,
                    'textHeight', self.db.txtSize,
                    'textWidth', self.db.txtSize,
                    'func', function() self.reorderEnchantMenu = not self.reorderEnchantMenu end,
                    'notCheckable', true,
                    'tooltipText', "Left click to move up\nRight click to move down"
                )
            self.dewdrop:AddLine(
		    	'text', "Close Menu",
                'textHeight', self.db.txtSize,
                'textWidth', self.db.txtSize,
                'textR', 0,
                'textG', 1,
                'textB', 1,
				'closeWhenClicked', true,
				'notCheckable', true
		    )
		end,
		'dontHook', true
	)
    self.dewdrop:Open(button)
end

function SPM:FavoriteClick(arg1)
    local specNum
    self.dewdrop:Close()
    if (arg1=="LeftButton") then
        if self.db.Specs[self:GetSpecId()][1] == "LastSpec" then
            specNum = self.db.LastSpec
        else
            specNum =  self.db.Specs[self:GetSpecId()][1]
        end
    elseif (arg1=="RightButton") then
        if self.db.Specs[self:GetSpecId()][2] == "LastSpec" then
            specNum = self.db.LastSpec
        else
        specNum =  self.db.Specs[self:GetSpecId()][2]
        end
    end
    if specNum ~= self:GetSpecId() then
        if IsMounted() then Dismount() end
        self.lastActiveSpec = self:GetSpecId()
        self.specNum = specNum
        local spell = SpecializationUtil.GetSpecializationSpell(specNum)
        CastSpecialSpell(spell)
    else
        DEFAULT_CHAT_FRAME:AddMessage(CYAN.."Spec is already active")
    end
end

function SPM:MenuClick(button, arg1)
    GameTooltip:Hide()
    if (arg1=="LeftButton") then
        self:DewdropRegister(button, true)
    elseif (arg1=="RightButton") then
        self:EnchantPreset_DewdropRegister(button)
    end
end

-- Used to show highlight as a frame mover
function SPM:UnlockFrame()
    self = SPM
    if self.unlocked then
        SpecMenuFrame_Menu:Show()
        SpecMenuFrame_Favorite:Show()
        SpecMenuFrame.Highlight:Hide()
        self.unlocked = false
        GameTooltip:Hide()
        if self.db.ShowMenuOnHover then
            self.standaloneButton:SetAlpha(0)
        end
    else
        SpecMenuFrame_Menu:Hide()
        SpecMenuFrame_Favorite:Hide()
        SpecMenuFrame.Highlight:Show()
        self.unlocked = true
        if self.db.ShowMenuOnHover then
            self.standaloneButton:SetAlpha(10)
        end
    end
end

function SPM:ADDON_LOADED(event, arg1, arg2, arg3)
	-- setup for auction house window
	if event == "ADDON_LOADED" and arg1 == "Ascension_CharacterAdvancement" then
        CharacterAdvancementSideBarSpecListNineSlice:HookScript("OnHide", function()
            local name, icon = self:GetSpecInfo(self:GetSpecId())
            SpecMenuFrame.icon:SetTexture(icon)
            SPM:SetMapIcon(icon)
        end)
	end
end

-- toggle the main button frame
function SPM:ToggleMainFrame()
    if self.standaloneButton:IsVisible() then
        self.standaloneButton:Hide()
    else
        self.standaloneButton:Show()
    end
end

--[[
SlashCommand(msg):
msg - takes the argument for the /mysticextended command so that the appropriate action can be performed
If someone types /mysticextended, bring up the options box
]]
function SPM:SlashCommandInitialize()
    local function SlashCommand(msg)
        if msg == "reset" then
            SpecMenuDB = nil
            self:OnInitialize()
            DEFAULT_CHAT_FRAME:AddMessage("Settings Reset")
        elseif msg == "options" then
            SPM:OptionsToggle()
        elseif msg == "resetbutton" then
            self.standaloneButton:Show()
            self.standaloneButton:ClearAllPoints()
            self.standaloneButton:SetPoint("CENTER",UIParent ,"CENTER",0,0)
        else
            self:ToggleMainFrame()
        end
    end

    --Enable the use of /me or /mysticextended to open the loot browser
    SLASH_SPECMENU1 = "/specmenu"
    SLASH_SPECMENU2 = "/spm"
    SlashCmdList["SPECMENU"] = function(msg)
        SlashCommand(msg)
    end
end

function SPM:OnEnter(button,  showUnlock)
    if self.db.autoMenu and not UnitAffectingCombat("player") then
        if IsAltKeyDown() then
            self:EnchantPreset_DewdropRegister(button)
        else
            self:DewdropRegister(button, showUnlock)
        end
    else
        GameTooltip:SetOwner(button, 'ANCHOR_NONE')
        GameTooltip:SetPoint(SPM:GetTipAnchor(button))
        GameTooltip:ClearLines()
        local specID, presetID, presetName, specName = self:GetSpecId(), self:GetPresetId()
        specName = "|cffffffff"..self:GetSpecInfo(specID)
        presetName = "|cffffffff"..self:GetPresetName(presetID)
        GameTooltip:AddLine("SpecMenu")
        GameTooltip:AddDoubleLine("Active Spec:", specName)
        GameTooltip:AddDoubleLine("Active Enchant Spec:", presetName)
        GameTooltip:Show()
    end
end

function SPM:SetDisplayText()
    local specName = "S: |cffffffff"..SPM:GetSpecInfo(SPM:GetSpecId())
    local presetName = "E: |cffffffff"..SPM:GetPresetName(SPM:GetPresetId())
    SpecDisplayFrame.text:SetText(specName)
    SpecDisplayFrame.text2:SetText(presetName)
    if SpecDisplayFrame.text:GetWidth() > SpecDisplayFrame.text2:GetWidth() then
        SpecDisplayFrame:SetWidth(SpecDisplayFrame.text:GetWidth() +30)
    else
        SpecDisplayFrame:SetWidth(SpecDisplayFrame.text2:GetWidth() +30)
    end
end

function SPM:SetFrameAlpha()
    if self.db.ShowMenuOnHover then
        self.standaloneButton:SetAlpha(0)
    else
        self.standaloneButton:SetAlpha(10)
    end
end