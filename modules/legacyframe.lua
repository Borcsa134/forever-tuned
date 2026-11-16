local LegacyFrameModule = {}
ForeverTuned.modules.LegacyFrame = LegacyFrameModule

local TAB_SPECS = {
    { id = 1, label = "Reward Track" },
    { id = 2, label = "Challenges" },
    { id = 3, label = "Tree" },
}

function LegacyFrameModule:Initialize()
    if not ForeverTuned.modules.Config:GetSetting("legacyTabsAtBottom") then
        return
    end
    self:MoveTabsToBottom()
end

function LegacyFrameModule:MoveTabsToBottom()
    if LegacySystemFrame then
        self:Setup()
        return
    end
    local waiter = CreateFrame("Frame")
    waiter:RegisterEvent("ADDON_LOADED")
    waiter:SetScript("OnEvent", function(selfFrame, event, addon)
        if addon == "Blizzard_LegacySystem" then
            selfFrame:UnregisterEvent("ADDON_LOADED")
            LegacyFrameModule:Setup()
        end
    end)
end

local function GetNativeTabs()
    local frame = LegacySystemFrame
    if not frame or not frame.Tabs then return {} end
    local tabs = {}
    for _, tab in ipairs(frame.Tabs) do
        tabs[#tabs + 1] = tab
    end
    return tabs
end

function LegacyFrameModule:Setup()
    local frame = LegacySystemFrame
    if not frame or self.setupDone then return end
    self.setupDone = true

    for _, tab in ipairs(GetNativeTabs()) do
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

    self.overlays = {}
    for i, spec in ipairs(TAB_SPECS) do
        local overlay = CreateFrame("Button", "ForeverTunedLegacyTab" .. i, frame, "PanelTabButtonTemplate")
        overlay:SetID(spec.id)
        overlay:SetText(spec.label)
        if PanelTemplates_TabResize then PanelTemplates_TabResize(overlay, 0) end
        overlay:SetScript("OnClick", function()
            EventRegistry:TriggerEvent("Legacy.SelectPage", spec.id)
        end)
        self.overlays[i] = overlay
    end

    self.overlays[1]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
    for i = 2, #self.overlays do
        self.overlays[i]:SetPoint("LEFT", self.overlays[i - 1], "RIGHT", 4, 0)
    end

    EventRegistry:RegisterCallback("Legacy.SelectPage", function(_, id)
        LegacyFrameModule:UpdateHighlights(id)
    end, self)

    frame:HookScript("OnShow", function()
        LegacyFrameModule:UpdateHighlights(frame.currentPage)
    end)

    self:UpdateHighlights(frame.currentPage)
end

function LegacyFrameModule:UpdateHighlights(activeID)
    if not self.overlays then return end
    local activeIndex = 1
    for i, spec in ipairs(TAB_SPECS) do
        if spec.id == activeID then
            activeIndex = i
            break
        end
    end
    for i, overlay in ipairs(self.overlays) do
        if i == activeIndex then
            PanelTemplates_SelectTab(overlay)
        else
            PanelTemplates_DeselectTab(overlay)
        end
    end
end

function LegacyFrameModule:OnLogout()
end
