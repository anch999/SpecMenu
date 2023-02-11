local SPM = LibStub("AceAddon-3.0"):GetAddon("SpecMenu")
local mainframe = CreateFrame("FRAME", "SpecMenuPopupFrame", UIParent,"UIPanelDialogTemplate")
    mainframe:SetPoint("CENTER",0,0);
    mainframe:SetSize(500,120);
    mainframe:EnableMouse(true);
    mainframe:SetMovable(true);
    mainframe:RegisterForDrag("LeftButton");
    mainframe:SetScript("OnDragStart", function(self) mainframe:StartMoving() end)
    mainframe:SetScript("OnDragStop", function(self) mainframe:StopMovingOrSizing() end)
    mainframe.TitleText = mainframe:CreateFontString();
    mainframe.TitleText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    mainframe.TitleText:SetFontObject(GameFontNormal)
    mainframe.TitleText:SetText("Spec Change Popup");
    mainframe.TitleText:SetPoint("TOP", 0, -9);
    mainframe.TitleText:SetShadowOffset(1,-1);
    mainframe:Hide();
