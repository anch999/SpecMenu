local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")

local specbutton, mainframe
function SPM:CreateMainUI()

    --Creates the main interface
        mainframe = CreateFrame("Button", "SpecMenuFrame", UIParent, nil)
        mainframe:SetSize(70,70)
        mainframe:EnableMouse(true)
        mainframe:RegisterForDrag("LeftButton")
        mainframe:SetScript("OnDragStart", function() mainframe:StartMoving() end)
        mainframe:SetScript("OnDragStop", function() mainframe:StopMovingOrSizing() end)
        mainframe:SetMovable(true)
        mainframe:RegisterForClicks("RightButtonDown")
        mainframe:SetScript("OnClick", function(button, btnclick) if self.unlocked then self:UnlockFrame() end end)
        mainframe.icon = mainframe:CreateTexture(nil, "ARTWORK")
        mainframe.icon:SetSize(55,55)
        mainframe.icon:SetPoint("CENTER", mainframe,"CENTER",0,0)
        mainframe.Text = mainframe:CreateFontString()
        mainframe.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
        mainframe.Text:SetFontObject(GameFontNormal)
        mainframe.Text:SetText("|cffffffffSpec\nMenu")
        mainframe.Text:SetPoint("CENTER", mainframe.icon, "CENTER", 0, 0)
        mainframe.Highlight = mainframe:CreateTexture(nil, "OVERLAY")
        mainframe.Highlight:SetSize(70,70)
        mainframe.Highlight:SetPoint("CENTER", mainframe, 0, 0)
        mainframe.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        mainframe.Highlight:Hide()
        mainframe:Hide()
        mainframe:SetScript("OnEnter", function(button) 
            if self.unlocked then
                GameTooltip:SetOwner(button, "ANCHOR_TOP")
                GameTooltip:AddLine("Left click to drag")
                GameTooltip:AddLine("Right click to lock frame")
                GameTooltip:Show()
            else
                self:ToggleMainButton("show")
            end
        end)
        mainframe:SetScript("OnLeave", function() GameTooltip:Hide() end)

        specbutton = CreateFrame("Button", "SpecMenuFrame_Menu", SpecMenuFrame)
        specbutton:SetSize(70,34)
        specbutton:SetPoint("BOTTOM", SpecMenuFrame, "BOTTOM", 0, 2)
        specbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        specbutton:SetScript("OnClick", function(button, btnclick) self:MainButton_OnClick(button, btnclick) end)
        specbutton.Highlight = specbutton:CreateTexture(nil, "OVERLAY")
        specbutton.Highlight:SetSize(70,34)
        specbutton.Highlight:SetPoint("CENTER", specbutton, 0, 0)
        specbutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        specbutton.Highlight:Hide()
        specbutton:SetScript("OnEnter", function(button)
            self:OnEnter(button, true)
            specbutton.Highlight:Show()
            self:ToggleMainButton("show")
        end)
        specbutton:SetScript("OnLeave", function()
            specbutton.Highlight:Hide()
            GameTooltip:Hide()
            self:ToggleMainButton("hide")
        end)
    
        local favoritebutton = CreateFrame("Button", "SpecMenuFrame_Favorite", SpecMenuFrame)
        favoritebutton:SetSize(70,34)
        favoritebutton:SetPoint("TOP", SpecMenuFrame, "TOP", 0, -2)
        favoritebutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        favoritebutton:SetScript("OnClick", function(button, btnclick) self:Favorite_OnClick(btnclick) end)
        favoritebutton.Highlight = favoritebutton:CreateTexture(nil, "OVERLAY")
        favoritebutton.Highlight:SetSize(70,34)
        favoritebutton.Highlight:SetPoint("CENTER", favoritebutton, 0, 0)
        favoritebutton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
        favoritebutton.Highlight:Hide()
        favoritebutton:SetScript("OnEnter", function(button)
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
            self:ToggleMainButton("show")
            favoritebutton.Highlight:Show()
        end)
        favoritebutton:SetScript("OnLeave", function()
            favoritebutton.Highlight:Hide()
            GameTooltip:Hide()
            self:ToggleMainButton("hide")
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