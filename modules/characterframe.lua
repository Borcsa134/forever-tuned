local CharacterFrameModule = {}
ForeverTuned.modules.CharacterFrame = CharacterFrameModule

local TAB_SPECS = {
    {
        label = "Character",
        panel = "PaperDollFrame",
        activate = function() ToggleCharacter("PaperDollFrame", true) end,
    },
    {
        label = "Reputation",
        panel = "ReputationFrame",
        activate = function() ToggleCharacter("ReputationFrame", true) end,
    },
    {
        label = "Currency",
        panel = "TokenFrame",
        activate = function() ToggleCharacter("TokenFrame", true) end,
    },
    {
        label = "PvP",
        panel = "PVPRankFrame",
        activate = function() ToggleCharacter("PVPRankFrame", true) end,
    },
    {
        label = "Skills",
        panel = "SkillsFrame",
        activate = function() ToggleCharacter("SkillsFrame", true) end,
    },
    {
        label = "Statistics",
        panel = "StatisticsFrame",
        activate = function() ToggleCharacter("StatisticsFrame", true) end,
    },
}

function CharacterFrameModule:Initialize()
    if ForeverTuned.modules.Config:GetSetting("characterTabsAtBottom") then
        self:MoveTabsToBottom()
    end
end

function CharacterFrameModule:MoveTabsToBottom()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function()
        CharacterFrameModule:RepositionTabs()
    end)

    self:RepositionTabs()
end

local function GetNativeTabs()
    local tabs = {}
    for i = 1, 6 do
        tabs[#tabs + 1] = _G["CharacterFrameTab" .. i]
        tabs[#tabs + 1] = _G["CharacterFrameModeTab" .. i]
    end
    return tabs
end

local function UpdateTabHighlights(overlays)
    local active = 1
    for i, spec in ipairs(TAB_SPECS) do
        local panel = _G[spec.panel]
        if panel and panel:IsShown() then
            active = i
            break
        end
    end

    CharacterFrame.numTabs = #overlays
    if PanelTemplates_SetTab then
        PanelTemplates_SetTab(CharacterFrame, active)
    end
    for i, overlay in ipairs(overlays) do
        if i == active then overlay:Disable() else overlay:Enable() end
    end
end

function CharacterFrameModule:RepositionTabs()
    C_Timer.After(0.1, function()
        local nativeTabs = GetNativeTabs()
        for _, tab in ipairs(nativeTabs) do
            if tab then
                tab:Hide()
                if not tab.foreverTunedHidden then
                    tab.foreverTunedHidden = true
                    hooksecurefunc(tab, "Show", function(self)
                        if not self.foreverTunedHiding then
                            self.foreverTunedHiding = true
                            self:Hide()
                            self.foreverTunedHiding = false
                        end
                    end)
                end
            end
        end

        if CharacterFrameRightPaneToggleButton then
            CharacterFrameRightPaneToggleButton:Hide()
        end

        if not self.overlays then
            self.overlays = {}
            for i, spec in ipairs(TAB_SPECS) do
                local overlay = CreateFrame("Button", "ForeverTunedCharTab" .. i, CharacterFrame, "PanelTabButtonTemplate")
                overlay:SetID(i)
                overlay:SetText(spec.label)
                if PanelTemplates_TabResize then PanelTemplates_TabResize(overlay, 0) end
                overlay:SetScript("OnClick", function()
                    spec.activate()
                    UpdateTabHighlights(self.overlays)
                end)
                self.overlays[i] = overlay
            end

            self.overlays[1]:SetPoint("TOPLEFT", CharacterFrame, "BOTTOMLEFT", 10, 2)
            for i = 2, #self.overlays do
                self.overlays[i]:SetPoint("LEFT", self.overlays[i - 1], "RIGHT", 4, 0)
            end
        end

        for _, overlay in ipairs(self.overlays) do
            overlay:Show()
        end

        if not self.panelHooksSet then
            self.panelHooksSet = true
            for _, spec in ipairs(TAB_SPECS) do
                local panel = _G[spec.panel]
                if panel then
                    panel:HookScript("OnShow", function() UpdateTabHighlights(self.overlays) end)
                    panel:HookScript("OnHide", function() UpdateTabHighlights(self.overlays) end)
                end
            end
        end

        UpdateTabHighlights(self.overlays)
    end)
end

function CharacterFrameModule:OnLogout()
end
