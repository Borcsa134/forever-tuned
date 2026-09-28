local CharacterFrameModule = {}
ForeverTuned.modules.CharacterFrame = CharacterFrameModule

local INACTIVE_TAB = "Interface\\PaperDollInfoFrame\\UI-Character-InActiveTab"
local ACTIVE_TAB   = "Interface\\PaperDollInfoFrame\\UI-Character-ActiveTab"

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

function CharacterFrameModule:RepositionTabs()
    C_Timer.After(0.1, function()
        local tabs = {
            CharacterFrameModeTab1,
            CharacterFrameModeTab2,
            CharacterFrameModeTab3,
            CharacterFrameModeTab4,
            CharacterFrameModeTab5,
            CharacterFrameModeTab6
        }

        local panelNames = {
            "PaperDollFrame",
            "ReputationFrame",
            "SkillsFrame",
            "PVPRankFrame",
            "TokenFrame",
            "StatisticsFrame",
        }

        local labels = {
            "Character",
            "Reputation",
            "Skills",
            "PvP",
            "Currency",
            "Statistics",
        }

        local tabWidth = 96
        local tabHeight = 30
        local spacing = tabWidth - 12
        local startX = 4

        for i, tab in ipairs(tabs) do
            if tab then
                tab:ClearAllPoints()
                tab:SetSize(tabWidth, tabHeight)
                tab:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", startX + ((i - 1) * spacing), -tabHeight)
                tab:SetAlpha(0)

                if not tab.ftOverlay then
                    local ov = CreateFrame("Frame", nil, CharacterFrame)
                    ov:SetSize(tabWidth, tabHeight)
                    ov:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, 0)
                    ov:SetFrameLevel(tab:GetFrameLevel() + 2)

                    ov.left = ov:CreateTexture(nil, "BACKGROUND")
                    ov.left:SetSize(20, 32)
                    ov.left:SetPoint("TOPLEFT", ov, "TOPLEFT", 0, 0)
                    ov.left:SetTexture(INACTIVE_TAB)
                    ov.left:SetTexCoord(0, 0.15625, 0, 1)

                    ov.right = ov:CreateTexture(nil, "BACKGROUND")
                    ov.right:SetSize(20, 32)
                    ov.right:SetPoint("TOPRIGHT", ov, "TOPRIGHT", 0, 0)
                    ov.right:SetTexture(INACTIVE_TAB)
                    ov.right:SetTexCoord(0.84375, 1, 0, 1)

                    ov.middle = ov:CreateTexture(nil, "BACKGROUND")
                    ov.middle:SetPoint("TOPLEFT", ov.left, "TOPRIGHT", 0, 0)
                    ov.middle:SetPoint("TOPRIGHT", ov.right, "TOPLEFT", 0, 0)
                    ov.middle:SetHeight(32)
                    ov.middle:SetTexture(INACTIVE_TAB)
                    ov.middle:SetTexCoord(0.15625, 0.84375, 0, 1)

                    ov.label = ov:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    ov.label:SetPoint("CENTER", ov, "CENTER", 0, 2)

                    tab.ftOverlay = ov
                end
                tab.ftOverlay.label:SetText(labels[i] or "")
            end
        end

        local function updateTabHighlights()
            for i, tab in ipairs(tabs) do
                local ov = tab and tab.ftOverlay
                if ov then
                    local panel = panelNames[i] and _G[panelNames[i]]
                    local selected = panel and panel:IsShown()
                    local tex = selected and ACTIVE_TAB or INACTIVE_TAB
                    local h = selected and (tabHeight + 20) or tabHeight

                    ov:ClearAllPoints()
                    ov:SetSize(tabWidth, h)
                    ov:SetPoint("BOTTOMLEFT", tab, "BOTTOMLEFT", 0, selected and -20 or 0)

                    ov.left:SetSize(20, h)
                    ov.right:SetSize(20, h)
                    ov.middle:SetHeight(h)

                    ov.left:SetTexture(tex)
                    ov.middle:SetTexture(tex)
                    ov.right:SetTexture(tex)

                    ov.label:ClearAllPoints()
                    ov.label:SetPoint("CENTER", ov, 0, selected and 12 or 2)
                    ov.label:SetTextColor(selected and 1 or 1, selected and 1 or 0.82, selected and 1 or 0)
                end
            end
        end

        for i, name in ipairs(panelNames) do
            local panel = _G[name]
            if panel then
                panel:HookScript("OnShow", updateTabHighlights)
                panel:HookScript("OnHide", updateTabHighlights)
            end
        end

        updateTabHighlights()
    end)
end

function CharacterFrameModule:OnLogout()
end
