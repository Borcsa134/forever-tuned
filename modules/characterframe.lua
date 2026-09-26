local CharacterFrameModule = {}
ForeverTuned.modules.CharacterFrame = CharacterFrameModule

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

        local spacing = 60
        local startX = 4

        for i, tab in ipairs(tabs) do
            if tab then
                tab:ClearAllPoints()
                tab:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMLEFT", startX + ((i - 1) * spacing), -58)

                local angle = math.rad(-90)

                if tab.Background then
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
            end
        end
    end)
end

function CharacterFrameModule:OnLogout()
end
