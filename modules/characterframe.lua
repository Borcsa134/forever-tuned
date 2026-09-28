local CharacterFrameModule = {}
ForeverTuned.modules.CharacterFrame = CharacterFrameModule

local INACTIVE_TAB = "Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab"
local ACTIVE_TAB   = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab"

local TEXT_TAB_WIDTH   = 96
local TEXT_TAB_HEIGHT  = 30
local TEXT_TAB_SPACING = 84
local TEXT_TAB_Y       = -30

local ICON_TAB_SIZE    = 60
local ICON_TAB_SPACING = 60
local ICON_TAB_Y       = -60

local PANEL_NAMES = {
    "PaperDollFrame",
    "ReputationFrame",
    "SkillsFrame",
    "PVPRankFrame",
    "TokenFrame",
    "StatisticsFrame",
}

local TAB_LABELS = {
    "Character",
    "Reputation",
    "Skills",
    "PvP",
    "Currency",
    "Statistics",
}

function CharacterFrameModule:Initialize()
    if ForeverTuned.modules.Config:GetSetting("characterTabsAtBottom") then
        self:MoveTabsToBottom()
    end
end

function CharacterFrameModule:MoveTabsToBottom()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(self, event, addon)
        if addon == "Blizzard_PlayerSpells" or event == "PLAYER_ENTERING_WORLD" then
            CharacterFrameModule:RepositionTabs()
        end
    end)

    self:RepositionTabs()
end

local function SetupTextTab(tab, index)
    tab:SetAlpha(0)

    if not tab.ftOverlay then
        local ov = CreateFrame("Frame", nil, CharacterFrame)
        ov:SetSize(TEXT_TAB_WIDTH, TEXT_TAB_HEIGHT)
        ov:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
        ov:SetFrameLevel(tab:GetFrameLevel() + 2)

        ov.left = ov:CreateTexture(nil, "BACKGROUND")
        ov.left:SetSize(20, TEXT_TAB_HEIGHT)
        ov.left:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, 0)
        ov.left:SetTexture(INACTIVE_TAB)
        ov.left:SetTexCoord(0, 0.15625, 0, 1)

        ov.right = ov:CreateTexture(nil, "BACKGROUND")
        ov.right:SetSize(20, TEXT_TAB_HEIGHT)
        ov.right:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, 0)
        ov.right:SetTexture(INACTIVE_TAB)
        ov.right:SetTexCoord(0.84375, 1, 0, 1)

        ov.middle = ov:CreateTexture(nil, "BACKGROUND")
        ov.middle:SetPoint("TOPLEFT", ov.left, "TOPRIGHT", 0, 0)
        ov.middle:SetPoint("TOPRIGHT", ov.right, "TOPLEFT", 0, 0)
        ov.middle:SetHeight(TEXT_TAB_HEIGHT)
        ov.middle:SetTexture(INACTIVE_TAB)
        ov.middle:SetTexCoord(0.15625, 0.84375, 0, 1)

        ov.label = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        ov.label:SetPoint("CENTER", ov, "CENTER", 0, 2)

        tab.ftOverlay = ov
    end

    tab.ftOverlay.label:SetText(TAB_LABELS[index] or "")
    tab.ftOverlay:Show()
end

local function SetupIconTab(tab)
    tab:SetAlpha(1)
    if tab.ftOverlay then tab.ftOverlay:Hide() end

    local angle = math.rad(-90)
    if tab.Background then
        tab.Background:Show()
        tab.Background:SetRotation(angle)
    end
    if tab.SelectedTexture then
        tab.SelectedTexture:SetRotation(angle)
    end
    if tab.HighlightTexture then
        tab.HighlightTexture:SetRotation(angle)
    end
    if tab.Mask then
        tab.Mask:SetRotation(angle)
    end
    if tab.Icon then
        tab.Icon:Show()
    end
end

local function UpdateTextTabHighlights(tabs)
    for i, tab in ipairs(tabs) do
        local ov = tab and tab.ftOverlay
        if ov and ov:IsShown() then
            local panel = _G[PANEL_NAMES[i]]
            local selected = panel and panel:IsShown()
            local tex = selected and ACTIVE_TAB or INACTIVE_TAB
            local h = selected and (TEXT_TAB_HEIGHT + 20) or TEXT_TAB_HEIGHT

            ov:ClearAllPoints()
            ov:SetSize(TEXT_TAB_WIDTH, h)
            ov:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, selected and -20 or 0)

            ov.left:SetSize(20, h)
            ov.right:SetSize(20, h)
            ov.middle:SetHeight(h)
            ov.left:SetTexture(tex)
            ov.middle:SetTexture(tex)
            ov.right:SetTexture(tex)

            ov.label:ClearAllPoints()
            ov.label:SetPoint("CENTER", ov, "CENTER", 0, selected and 12 or 2)
            ov.label:SetTextColor(selected and 1 or 1, selected and 1 or 0.82, selected and 1 or 0)
        end
    end
end

function CharacterFrameModule:RepositionTabs()
    C_Timer.After(0.1, function()
        local tabs = {
            CharacterFrameModeTab1,
            CharacterFrameModeTab2,
            CharacterFrameModeTab3,
            CharacterFrameModeTab4,
            CharacterFrameModeTab5,
            CharacterFrameModeTab6,
        }

        local textMode = ForeverTuned.modules.Config:GetSetting("characterTabsTextMode")
        local tabWidth   = textMode and TEXT_TAB_WIDTH   or ICON_TAB_SIZE
        local tabHeight  = textMode and TEXT_TAB_HEIGHT  or ICON_TAB_SIZE
        local spacing    = textMode and TEXT_TAB_SPACING or ICON_TAB_SPACING
        local yOffset    = textMode and TEXT_TAB_Y       or ICON_TAB_Y

        for i, tab in ipairs(tabs) do
            if tab then
                tab:ClearAllPoints()
                tab:SetSize(tabWidth, tabHeight)
                tab:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", 4 + ((i - 1) * spacing), yOffset)

                if textMode then
                    SetupTextTab(tab, i)
                else
                    SetupIconTab(tab)
                end
            end
        end

        if textMode then
            local function onPanelVisibilityChanged()
                UpdateTextTabHighlights(tabs)
            end

            for _, name in ipairs(PANEL_NAMES) do
                local panel = _G[name]
                if panel then
                    panel:HookScript("OnShow", onPanelVisibilityChanged)
                    panel:HookScript("OnHide", onPanelVisibilityChanged)
                end
            end

            UpdateTextTabHighlights(tabs)
        end
    end)
end

function CharacterFrameModule:OnLogout()
end
