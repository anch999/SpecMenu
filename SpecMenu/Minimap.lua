local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

local icon = LibStub('LibDBIcon-1.0')
local defIcon = "Interface\\Icons\\inv_misc_book_16"

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("SpecMenu", {
    type = 'data source',
    text = "SpecMenu",
    icon = defIcon,
  })

function SPM:GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    if button == "LeftButton" then
        SPM:DewdropRegister(self)
    elseif button == "RightButton" then
        SPM:EnchantPreset_DewdropRegister(self)
    end
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnEnter(self)
    SPM:OnEnter(self)
end

function SPM:ToggleMinimap()
    local hide = not self.db.minimap
    self.db.minimap = hide
    if hide then
      icon:Hide('SpecMenu')
    else
      icon:Show('SpecMenu')
    end
end

function SPM:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register('SpecMenu', minimap, self.minimap)
    end
    minimap.icon = icon
end