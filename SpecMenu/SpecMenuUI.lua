local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

function SPM:CreateMainUI()

    --Creates the main interface
        self.standaloneFrame = CreateFrame("Button", "SpecMenuFrame", UIParent, nil)
        self.standaloneFrame:SetSize(70,70)
        self.standaloneFrame:EnableMouse(true)
        self.standaloneFrame:RegisterForDrag("LeftButton")
        self.standaloneFrame:SetScript("OnDragStart", function() self.standaloneFrame:StartMoving() end)
        self.standaloneFrame:SetScript("OnDragStop", function() self.standaloneFrame:StopMovingOrSizing() end)
        self.standaloneFrame:SetMovable(true)
        self.standaloneFrame:RegisterForClicks("RightButtonDown")
        self.standaloneFrame:SetScript("OnClick", function(button, btnclick) if self.unlocked then self:UnlockFrame() end end)
        self.standaloneFrame.icon = self.standaloneFrame:CreateTexture(nil, "ARTWORK")
        self.standaloneFrame.icon:SetSize(55,55)
        self.standaloneFrame.icon:SetPoint("CENTER", self.standaloneFrame,"CENTER",0,0)
        self.standaloneFrame.Text = self.standaloneFrame:CreateFontString()
        self.standaloneFrame.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
        self.standaloneFrame.Text:SetFontObject(GameFontNormal)
        self.standaloneFrame.Text:SetText("|cffffffffSpec\nMenu")
        self.standaloneFrame.Text:SetPoint("CENTER", self.standaloneFrame.icon, "CENTER", 0, 0)
        self.standaloneFrame.Highlight = self.standaloneFrame:CreateTexture(nil, "OVERLAY")
        self.standaloneFrame.Highlight:SetSize(70,70)
        self.standaloneFrame.Highlight:SetPoint("CENTER", self.standaloneFrame, 0, 0)
        self.standaloneFrame.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneFrame.Highlight:Hide()
        self.standaloneFrame:Hide()
        self.standaloneFrame:SetScript("OnEnter", function(button)
            if self.unlocked then
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:AddLine("Left click to drag")
                GameTooltip:AddLine("Right click to lock frame")
                GameTooltip:Show()
            else
                self:ToggleStandaloneButton("show")
            end
        end)
        self.standaloneFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

        self.standaloneFrame.specbutton = CreateFrame("Button", "SpecMenuFrame_Menu", SpecMenuFrame)
        self.standaloneFrame.specbutton:SetSize(70,34)
        self.standaloneFrame.specbutton:SetPoint("BOTTOM", SpecMenuFrame, "BOTTOM", 0, 2)
        self.standaloneFrame.specbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        self.standaloneFrame.specbutton:SetScript("OnClick", function(button, btnclick) self:MainButton_OnClick(button, btnclick) end)
        self.standaloneFrame.specbutton.Highlight = self.standaloneFrame.specbutton:CreateTexture(nil, "OVERLAY")
        self.standaloneFrame.specbutton.Highlight:SetSize(70,34)
        self.standaloneFrame.specbutton.Highlight:SetPoint("CENTER", self.standaloneFrame.specbutton, 0, 0)
        self.standaloneFrame.specbutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneFrame.specbutton.Highlight:Hide()
        self.standaloneFrame.specbutton:SetScript("OnEnter", function(button)
            self:OnEnter(button, true)
            self.standaloneFrame.specbutton.Highlight:Show()
            self:ToggleStandaloneButton("show")
        end)
        self.standaloneFrame.specbutton:SetScript("OnLeave", function()
            self.standaloneFrame.specbutton.Highlight:Hide()
            GameTooltip:Hide()
            self:ToggleStandaloneButton("hide")
        end)
    
        self.standaloneFrame.favoritebutton = CreateFrame("Button", "SpecMenuFrame_Favorite", SpecMenuFrame)
        self.standaloneFrame.favoritebutton:SetSize(70,34)
        self.standaloneFrame.favoritebutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -2)
        self.standaloneFrame.favoritebutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        self.standaloneFrame.favoritebutton:SetScript("OnClick", function(button, btnclick) self:Favorite_OnClick(btnclick) end)
        self.standaloneFrame.favoritebutton.Highlight = self.standaloneFrame.favoritebutton:CreateTexture(nil, "OVERLAY")
        self.standaloneFrame.favoritebutton.Highlight:SetSize(70,34)
        self.standaloneFrame.favoritebutton.Highlight:SetPoint("CENTER", self.standaloneFrame.favoritebutton, 0, 0)
        self.standaloneFrame.favoritebutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        self.standaloneFrame.favoritebutton.Highlight:Hide()
        self.standaloneFrame.favoritebutton:SetScript("OnEnter", function(button)
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
            self:ToggleStandaloneButton("show")
            self.standaloneFrame.favoritebutton.Highlight:Show()
        end)
        self.standaloneFrame.favoritebutton:SetScript("OnLeave", function()
            self.standaloneFrame.favoritebutton.Highlight:Hide()
            GameTooltip:Hide()
            self:ToggleStandaloneButton("hide")
        end)
end

SPM:CreateMainUI()

function SPM:CreateSpecDisplay()
    if self.specDisplayLoaded or self.db.hideSpecDisplay then return end
    --Creates the main interface
    local displayframe = CreateFrame("Frame", "SpecDisplayFrame", UIParent)
    displayframe:SetSize(200,50)
    displayframe:SetMovable(true)
    displayframe.Back = displayframe:CreateTexture(nil, "BACKGROUND")
    displayframe.Back:SetAllPoints()
    displayframe.Back:SetSize(200,50)
    displayframe.Back:SetPoint("CENTER",displayframe)
    displayframe:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    if self.db.hideSpecDisplayBackground then
        displayframe:SetBackdropColor(0, 0, 0, 0)
        displayframe:SetBackdropBorderColor(0, 0, 0, 0)
    else
        displayframe:SetBackdropColor(0, 0, 0, 5)
        displayframe:SetBackdropBorderColor(0, 0, 0, 5)
    end

    displayframe:EnableMouse(true)
    displayframe:RegisterForDrag("LeftButton")
    displayframe:SetScript("OnDragStart", function() displayframe:StartMoving() end)
    displayframe:SetScript("OnDragStop", function()
        displayframe:StopMovingOrSizing()
        self.db.DisplayPos = {displayframe:GetPoint()}
        self.db.DisplayPos[2] = "UIParent"
    end)
    displayframe:SetMovable(true)
    displayframe.text = displayframe:CreateFontString()
    displayframe.text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    displayframe.text:SetFontObject(GameFontNormal)
    displayframe.text:SetPoint("LEFT", displayframe, 10, 10)
    displayframe.text:SetJustifyH("LEFT")
    displayframe.text2 = displayframe:CreateFontString()
    displayframe.text2:SetFont("Fonts\\FRIZQT__.TTF", 13)
    displayframe.text2:SetFontObject(GameFontNormal)
    displayframe.text2:SetPoint("BOTTOMLEFT", displayframe.text, 0 ,-17)
    displayframe.text2:SetJustifyH("LEFT")
    self:SetDisplayText()
    
    if self.db.DisplayPos then
        local pos = self.db.DisplayPos
        displayframe:ClearAllPoints()
        displayframe:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        displayframe:ClearAllPoints()
        displayframe:SetPoint("CENTER", UIParent)
    end
    displayframe:SetScale(self.db.SpecDisplayScale or 1)
    displayframe:Show()
    self.specDisplayLoaded = true
end