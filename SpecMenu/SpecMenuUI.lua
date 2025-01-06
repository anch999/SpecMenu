local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

function SPM:CreateMainUI(icon)

    --Creates the main interface
        self.standaloneButton = CreateFrame("Button", "SpecMenuFrame", UIParent, nil)
        self.standaloneButton:SetSize(70,70)
        self.standaloneButton:EnableMouse(true)
        self.standaloneButton:RegisterForDrag("LeftButton")
        self.standaloneButton:SetScript("OnDragStart", function() self.standaloneButton:StartMoving() end)
        self.standaloneButton:SetScript("OnDragStop", function()
            self.standaloneButton:StopMovingOrSizing()
            self.db.standalonePosition = {self.standaloneButton:GetPoint()}
            self.db.standalonePosition[2] = "UIParent"
        end)
        self.standaloneButton:SetMovable(true)
        self.standaloneButton:RegisterForClicks("RightButtonDown")
        self.standaloneButton:SetScript("OnClick", function(button, btnclick) if self.unlocked then self:UnlockFrame() end end)
        self.standaloneButton:SetScale(self.db.buttonScale or 1)

        self.standaloneButton.icon = self.standaloneButton:CreateTexture(nil, "ARTWORK")
        self.standaloneButton.icon:SetSize(55,55)
        self.standaloneButton.icon:SetPoint("CENTER", self.standaloneButton,"CENTER",0,0)
        self.standaloneButton.Text = self.standaloneButton:CreateFontString()
        self.standaloneButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
        self.standaloneButton.Text:SetFontObject(GameFontNormal)
        self.standaloneButton.Text:SetText("|cffffffffSpec\nMenu")
        self.standaloneButton.Text:SetPoint("CENTER", self.standaloneButton.icon, "CENTER", 0, 0)
        self.standaloneButton.Highlight = self.standaloneButton:CreateTexture(nil, "OVERLAY")
        self.standaloneButton.Highlight:SetSize(70,70)
        self.standaloneButton.Highlight:SetPoint("CENTER", self.standaloneButton, 0, 0)
        self.standaloneButton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneButton.Highlight:Hide()
        self.standaloneButton:SetScript("OnEnter", function(button)
            if self.unlocked then
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:AddLine("Left click to drag")
                GameTooltip:AddLine("Right click to lock frame")
                GameTooltip:Show()
            end
            if self.db.ShowMenuOnHover and not UnitAffectingCombat("player") then
                self.standaloneButton:SetAlpha(10)
            end
        end)
        self.standaloneButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if self.db.ShowMenuOnHover and not self.unlocked then
                self.standaloneButton:SetAlpha(0)
            end
        end)

        self.standaloneButton.specbutton = CreateFrame("Button", "SpecMenuFrame_Menu", SpecMenuFrame)
        self.standaloneButton.specbutton:SetSize(70,34)
        self.standaloneButton.specbutton:SetPoint("BOTTOM", SpecMenuFrame, "BOTTOM", 0, 2)
        self.standaloneButton.specbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        self.standaloneButton.specbutton:SetScript("OnClick", function(button, btnclick) self:MenuClick(button, btnclick) end)
        self.standaloneButton.specbutton.Highlight = self.standaloneButton.specbutton:CreateTexture(nil, "OVERLAY")
        self.standaloneButton.specbutton.Highlight:SetSize(70,34)
        self.standaloneButton.specbutton.Highlight:SetPoint("CENTER", self.standaloneButton.specbutton, 0, 0)
        self.standaloneButton.specbutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneButton.specbutton.Highlight:Hide()
        self.standaloneButton.specbutton:SetScript("OnEnter", function(button)
            self:OnEnter(button, true)
            self.standaloneButton.specbutton.Highlight:Show()
            if self.db.ShowMenuOnHover and not UnitAffectingCombat("player") then
                self.standaloneButton:SetAlpha(10)
            end
        end)
        self.standaloneButton.specbutton:SetScript("OnLeave", function()
            self.standaloneButton.specbutton.Highlight:Hide()
            GameTooltip:Hide()
            if self.db.ShowMenuOnHover and not self.unlocked then
                self.standaloneButton:SetAlpha(0)
            end
        end)

        self.standaloneButton.favoritebutton = CreateFrame("Button", "SpecMenuFrame_Favorite", SpecMenuFrame)
        self.standaloneButton.favoritebutton:SetSize(70,34)
        self.standaloneButton.favoritebutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -2)
        self.standaloneButton.favoritebutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        self.standaloneButton.favoritebutton:SetScript("OnClick", function(button, btnclick) self:FavoriteClick(btnclick) end)
        self.standaloneButton.favoritebutton.Highlight = self.standaloneButton.favoritebutton:CreateTexture(nil, "OVERLAY")
        self.standaloneButton.favoritebutton.Highlight:SetSize(70,34)
        self.standaloneButton.favoritebutton.Highlight:SetPoint("CENTER", self.standaloneButton.favoritebutton, 0, 0)
        self.standaloneButton.favoritebutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneButton.favoritebutton.Highlight:Hide()
        self.standaloneButton.favoritebutton:SetScript("OnEnter", function(button)
            if not self.dewdrop:IsOpen() then
                if not CA_IsSpellKnown(self.SpecInfo[1]) then return end
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:AddLine("Favorite Specs")
                local leftTxt, rightTxt
                if self.db.Specs[self:GetSpecId()][1] == "LastSpec" then
                    leftTxt = "Last Spec"
                else
                    leftTxt = self:GetSpecInfo(self.db.Specs[self:GetSpecId()][1])
                end
                if self.db.Specs[self:GetSpecId()][2] == "LastSpec" then
                    rightTxt = "Last Spec"
                else
                    rightTxt = self:GetSpecInfo(self.db.Specs[self:GetSpecId()][2])
                end
                GameTooltip:AddDoubleLine("|cffffffff"..leftTxt,"|cffffffff"..rightTxt)
                GameTooltip:Show()
            end
            self.standaloneButton.favoritebutton.Highlight:Show()
            if self.db.ShowMenuOnHover and not UnitAffectingCombat("player") then
                self.standaloneButton:SetAlpha(10)
            end
        end)
        self.standaloneButton.favoritebutton:SetScript("OnLeave", function()
            self.standaloneButton.favoritebutton.Highlight:Hide()
            GameTooltip:Hide()
            if self.db.ShowMenuOnHover and not self.unlocked then
                self.standaloneButton:SetAlpha(0)
            end
        end)

        if self.db.HideMenu then
            self.standaloneButton:Hide()
        else
            self.standaloneButton:Show()
        end

        self:InitializeStandalonePosition()
        self:SetFrameAlpha()
        self.standaloneButton.icon:SetTexture(icon)
end

local specDisplayLoaded = false
function SPM:CreateSpecDisplay()
    if specDisplayLoaded or self.db.hideSpecDisplay then return end
    --Creates the main interface
    self.displayFrame = CreateFrame("Frame", "SpecDisplayFrame", UIParent)
    self.displayFrame:SetSize(200,50)
    self.displayFrame:SetMovable(true)
    self.displayFrame.Back = self.displayFrame:CreateTexture(nil, "BACKGROUND")
    self.displayFrame.Back:SetAllPoints()
    self.displayFrame.Back:SetSize(200,50)
    self.displayFrame.Back:SetPoint("CENTER",self.displayFrame)
    self.displayFrame:SetScale(self.db.SpecDisplayScale or 1)
    self.displayFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    if self.db.hideSpecDisplayBackground then
        self.displayFrame:SetBackdropColor(0, 0, 0, 0)
        self.displayFrame:SetBackdropBorderColor(0, 0, 0, 0)
    else
        self.displayFrame:SetBackdropColor(0, 0, 0, 5)
        self.displayFrame:SetBackdropBorderColor(0, 0, 0, 5)
    end

    self.displayFrame:EnableMouse(true)
    self.displayFrame:RegisterForDrag("LeftButton")
    self.displayFrame:SetScript("OnDragStart", function() self.displayFrame:StartMoving() end)
    self.displayFrame:SetScript("OnDragStop", function()
        self.displayFrame:StopMovingOrSizing()
        self.db.DisplayPos = {self.displayFrame:GetPoint()}
        self.db.DisplayPos[2] = "UIParent"
    end)
    self.displayFrame:SetMovable(true)
    self.displayFrame.text = self.displayFrame:CreateFontString()
    self.displayFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.displayFrame.text:SetFontObject(GameFontNormal)
    self.displayFrame.text:SetPoint("LEFT", self.displayFrame, 10, 10)
    self.displayFrame.text:SetJustifyH("LEFT")
    self.displayFrame.text2 = self.displayFrame:CreateFontString()
    self.displayFrame.text2:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.displayFrame.text2:SetFontObject(GameFontNormal)
    self.displayFrame.text2:SetPoint("BOTTOMLEFT", self.displayFrame.text, 0 ,-17)
    self.displayFrame.text2:SetJustifyH("LEFT")
    self:SetDisplayText()

    if self.db.DisplayPos then
        local pos = self.db.DisplayPos
        self.displayFrame:ClearAllPoints()
        self.displayFrame:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        self.displayFrame:ClearAllPoints()
        self.displayFrame:SetPoint("CENTER", UIParent)
    end
    self.displayFrame:SetScale(self.db.SpecDisplayScale or 1)
    self.displayFrame:Show()
    specDisplayLoaded = true
end

function SPM:InitializeStandalonePosition()
    if self.db.standalonePosition then
        local pos = self.db.standalonePosition
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint("CENTER", UIParent)
    end
end