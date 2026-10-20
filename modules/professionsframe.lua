local ProfessionsFrameModule = {}
ForeverTuned.modules.ProfessionsFrame = ProfessionsFrameModule

local function GetNativeTabs()
    local frame = ProfessionsFrame
    if not frame then return {} end
    local tabs = {}
    if frame.ProfessionsOverviewTab then
        tabs[#tabs + 1] = frame.ProfessionsOverviewTab
    end
    for i = 1, 5 do
        local t = frame["Professions" .. i .. "Tab"]
        if t then tabs[#tabs + 1] = t end
    end
    return tabs
end

local function GetSkillLine(nativeTab)
    return nativeTab.skillLine or nativeTab.skillLineID
end

local function GetTabLabel(nativeTab)
    local skillLine = GetSkillLine(nativeTab)
    if not skillLine then return "Overview" end
    if C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID then
        local ok, info = pcall(C_TradeSkillUI.GetProfessionInfoBySkillLineID, skillLine)
        if ok and info and info.professionName and info.professionName ~= "" then
            return info.professionName
        end
    end
    return "Profession"
end

function ProfessionsFrameModule:Initialize()
    if ForeverTuned.modules.Config:GetSetting("professionsTabsAtBottom") then
        self:MoveTabsToBottom()
    end
end

function ProfessionsFrameModule:MoveTabsToBottom()
    if ProfessionsFrame then
        self:Setup()
        return
    end
    local waiter = CreateFrame("Frame")
    waiter:RegisterEvent("ADDON_LOADED")
    waiter:SetScript("OnEvent", function(selfFrame, event, addon)
        if addon == "Blizzard_Professions" then
            selfFrame:UnregisterEvent("ADDON_LOADED")
            ProfessionsFrameModule:Setup()
        end
    end)
end

function ProfessionsFrameModule:Setup()
    local frame = ProfessionsFrame
    if not frame or self.setupDone then return end
    self.setupDone = true
    self.skins = {}
    self.skinPool = {}
    self.hookedTabs = {}

    EventRegistry:RegisterCallback("Professions.ProfessionSelected", function(_, info)
        ProfessionsFrameModule.activeSkillLine = info and info.professionID
        ProfessionsFrameModule:UpdateHighlights()
    end, self)

    EventRegistry:RegisterCallback("ProfessionsBookFrame.Show", function()
        ProfessionsFrameModule.activeSkillLine = nil
        ProfessionsFrameModule:UpdateHighlights()
    end, self)

    self:BuildTabs()

    local watcher = CreateFrame("Frame")
    watcher:RegisterEvent("SKILL_LINES_CHANGED")
    watcher:SetScript("OnEvent", function()
        ProfessionsFrameModule:BuildTabs()
    end)

    frame:HookScript("OnShow", function()
        ProfessionsFrameModule:UpdateHighlights()
    end)
end

function ProfessionsFrameModule:BuildTabs()
    C_Timer.After(0, function()
        local frame = ProfessionsFrame
        if not frame then return end

        for nativeTab, entry in pairs(self.skins) do
            nativeTab:SetParent(frame)
            entry.widget:Hide()
            entry.widget:ClearAllPoints()
        end
        self.skins = {}

        local nativeTabs = GetNativeTabs()
        local shown = {}
        for _, tab in ipairs(nativeTabs) do
            if tab:IsShown() then shown[#shown + 1] = tab end
        end

        local prev
        for i, nativeTab in ipairs(shown) do
            local skillLine = GetSkillLine(nativeTab)

            for _, region in ipairs({"Icon", "Background", "SelectedTexture", "Mask", "TabGlow", "HighlightTexture"}) do
                local r = nativeTab[region]
                if r and r.SetAlpha then r:SetAlpha(0) end
            end

            local skin = self.skinPool[i]
            if not skin then
                skin = CreateFrame("Button", "ForeverTunedProfSkin" .. i, frame, "PanelTabButtonTemplate")
                skin:EnableMouse(false)
                skin:SetFrameLevel(frame:GetFrameLevel() + 1)
                self.skinPool[i] = skin
            end
            skin:SetText(GetTabLabel(nativeTab))
            if PanelTemplates_TabResize then PanelTemplates_TabResize(skin, 0) end
            self.skins[nativeTab] = { widget = skin, skillLine = skillLine }

            nativeTab:SetParent(skin)
            nativeTab:SetAllPoints(skin)
            nativeTab:SetFrameLevel(skin:GetFrameLevel() + 5)
            nativeTab:EnableMouse(true)
            nativeTab:SetAlpha(1)
            if not self.hookedTabs[nativeTab] then
                self.hookedTabs[nativeTab] = true
                nativeTab:HookScript("OnMouseUp", function()
                    ProfessionsFrameModule.activeSkillLine = GetSkillLine(nativeTab)
                    ProfessionsFrameModule:UpdateHighlights()
                end)
            end

            skin:ClearAllPoints()
            if not prev then
                skin:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 10, 2)
            else
                skin:SetPoint("LEFT", prev, "RIGHT", 4, 0)
            end
            skin:Show()
            prev = skin
        end

        self:UpdateHighlights()
    end)
end

function ProfessionsFrameModule:UpdateHighlights()
    local nativeTabs = GetNativeTabs()
    local shown = {}
    for _, tab in ipairs(nativeTabs) do
        local entry = self.skins[tab]
        if entry and entry.widget:IsShown() then
            shown[#shown + 1] = { widget = entry.widget, skillLine = entry.skillLine }
        end
    end

    local activeIndex = 1
    for i, entry in ipairs(shown) do
        if entry.skillLine == self.activeSkillLine then
            activeIndex = i
            break
        end
    end

    ProfessionsFrame.numTabs = #shown
    for i, entry in ipairs(shown) do
        entry.widget:SetID(i)
        if i == activeIndex then
            entry.widget:Disable()
        else
            entry.widget:Enable()
        end
    end
    if PanelTemplates_SetTab then
        PanelTemplates_SetTab(ProfessionsFrame, activeIndex)
    end
end

function ProfessionsFrameModule:OnLogout()
end
