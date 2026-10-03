local Config = {}
ForeverTuned.modules.Config = Config

local configFrame
local minimapButton
local settingsChanged = false
local originalSettings = {}

function Config:Initialize()
    self:SetDefaults()
    self:CreateUI()
    self:CreateMinimapButton()
    self:RegisterSlashCommand()
end

function Config:SetDefaults()
    if ForeverTunedDB.settings.moveableCombinedBag == nil then
        ForeverTunedDB.settings.moveableCombinedBag = true
    end
    if ForeverTunedDB.settings.showTargetClassIcon == nil then
        ForeverTunedDB.settings.showTargetClassIcon = true
    end
    if ForeverTunedDB.settings.nameplateLevelOnLeft == nil then
        ForeverTunedDB.settings.nameplateLevelOnLeft = true
    end
    if ForeverTunedDB.settings.characterTabsAtBottom == nil then
        ForeverTunedDB.settings.characterTabsAtBottom = true
    end
    if ForeverTunedDB.settings.characterTabsTextMode == nil then
        ForeverTunedDB.settings.characterTabsTextMode = true
    end
    if ForeverTunedDB.settings.disableAutoGearCompare == nil then
        ForeverTunedDB.settings.disableAutoGearCompare = true
    end
    if ForeverTunedDB.settings.redIconOutOfRange == nil then
        ForeverTunedDB.settings.redIconOutOfRange = true
    end
    if ForeverTunedDB.settings.moveableBank == nil then
        ForeverTunedDB.settings.moveableBank = true
    end
end

function Config:GetSetting(key)
    return ForeverTunedDB.settings[key]
end

function Config:SetSetting(key, value)
    ForeverTunedDB.settings[key] = value
end

function Config:CreateUI()
    configFrame = CreateFrame("Frame", "ForeverTunedConfigFrame", UIParent, "PortraitFrameTemplate")
    configFrame:SetSize(680, 340)
    configFrame:SetPoint("CENTER")
    configFrame:SetMovable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:SetToplevel(true)
    configFrame:Hide()

    if configFrame.PortraitContainer.portrait then
        configFrame.PortraitContainer.portrait:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    end

    configFrame.title = configFrame.TitleContainer:CreateFontString(nil, "OVERLAY")
    configFrame.title:SetFontObject("GameFontNormal")
    configFrame.title:SetPoint("TOP", 0, -6)
    configFrame.title:SetText("ForeverTuned Settings")
    configFrame.title:SetTextColor(1, 0.82, 0)

    configFrame.CloseButton:SetScript("OnClick", function()
        if settingsChanged then
            Config:SetSetting("moveableCombinedBag", originalSettings.moveableCombinedBag)
            Config:SetSetting("moveableBank", originalSettings.moveableBank)
            Config:SetSetting("showTargetClassIcon", originalSettings.showTargetClassIcon)
            Config:SetSetting("nameplateLevelOnLeft", originalSettings.nameplateLevelOnLeft)
            Config:SetSetting("characterTabsAtBottom", originalSettings.characterTabsAtBottom)
            Config:SetSetting("characterTabsTextMode", originalSettings.characterTabsTextMode)
            Config:SetSetting("disableAutoGearCompare", originalSettings.disableAutoGearCompare)
            Config:SetSetting("redIconOutOfRange", originalSettings.redIconOutOfRange)
            settingsChanged = false
        end
        configFrame:Hide()
    end)

    local LEFT_X  = 20
    local RIGHT_X = 360
    local ly = -70
    local ry = -70

    -- LEFT COLUMN

    local bagsHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bagsHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", LEFT_X, ly)
    bagsHeader:SetText("Bags")
    ly = ly - 30
    ly = self:CreateMoveableBagCheckbox(ly, LEFT_X)
    ly = ly - 10
    ly = self:CreateMoveableBankCheckbox(ly, LEFT_X)
    ly = ly - 10

    local targetHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    targetHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", LEFT_X, ly)
    targetHeader:SetText("Target Frame")
    ly = ly - 30
    ly = self:CreateTargetClassIconCheckbox(ly, LEFT_X)
    ly = ly - 10

    local nameplatesHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameplatesHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", LEFT_X, ly)
    nameplatesHeader:SetText("Nameplates")
    ly = ly - 30
    ly = self:CreateNameplateLevelCheckbox(ly, LEFT_X)

    -- RIGHT COLUMN

    local characterHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    characterHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", RIGHT_X, ry)
    characterHeader:SetText("Character Frame")
    ry = ry - 30
    ry = self:CreateCharacterTabsCheckbox(ry, RIGHT_X)
    ry = self:CreateCharacterTabsTextModeCheckbox(ry, RIGHT_X)
    ry = ry - 10

    local tooltipHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    tooltipHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", RIGHT_X, ry)
    tooltipHeader:SetText("Tooltips")
    ry = ry - 30
    ry = self:CreateDisableAutoGearCompareCheckbox(ry, RIGHT_X)
    ry = ry - 10

    local actionBarHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    actionBarHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", RIGHT_X, ry)
    actionBarHeader:SetText("Action Bar")
    ry = ry - 30
    ry = self:CreateRedIconOutOfRangeCheckbox(ry, RIGHT_X)

    configFrame.closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configFrame.closeButton:SetSize(80, 22)
    configFrame.closeButton:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -10, 10)
    configFrame.closeButton:SetText("Close")
    configFrame.closeButton:SetScript("OnClick", function()
        if settingsChanged then
            Config:SetSetting("moveableCombinedBag", originalSettings.moveableCombinedBag)
            Config:SetSetting("moveableBank", originalSettings.moveableBank)
            Config:SetSetting("showTargetClassIcon", originalSettings.showTargetClassIcon)
            Config:SetSetting("nameplateLevelOnLeft", originalSettings.nameplateLevelOnLeft)
            Config:SetSetting("characterTabsAtBottom", originalSettings.characterTabsAtBottom)
            Config:SetSetting("characterTabsTextMode", originalSettings.characterTabsTextMode)
            Config:SetSetting("disableAutoGearCompare", originalSettings.disableAutoGearCompare)
            Config:SetSetting("redIconOutOfRange", originalSettings.redIconOutOfRange)
            settingsChanged = false
        end
        configFrame:Hide()
    end)

    configFrame.reloadButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configFrame.reloadButton:SetSize(80, 22)
    configFrame.reloadButton:SetPoint("RIGHT", configFrame.closeButton, "LEFT", -5, 0)
    configFrame.reloadButton:SetText("Reload")
    configFrame.reloadButton:Disable()
    configFrame.reloadButton:SetScript("OnClick", function()
        ReloadUI()
    end)
end

function Config:CreateMoveableBagCheckbox(yOffset, x)
    configFrame.moveableBagCheck = CreateFrame("CheckButton", "ForeverTunedConfigMoveableBag", configFrame, "UICheckButtonTemplate")
    configFrame.moveableBagCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.moveableBagCheck.text = configFrame.moveableBagCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.moveableBagCheck.text:SetPoint("LEFT", configFrame.moveableBagCheck, "RIGHT", 5, 0)
    configFrame.moveableBagCheck.text:SetText("Make combined bag moveable")
    configFrame.moveableBagCheck:SetChecked(self:GetSetting("moveableCombinedBag"))
    configFrame.moveableBagCheck:SetScript("OnClick", function(self)
        Config:SetSetting("moveableCombinedBag", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:CreateMoveableBankCheckbox(yOffset, x)
    configFrame.moveableBankCheck = CreateFrame("CheckButton", "ForeverTunedConfigMoveableBank", configFrame, "UICheckButtonTemplate")
    configFrame.moveableBankCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.moveableBankCheck.text = configFrame.moveableBankCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.moveableBankCheck.text:SetPoint("LEFT", configFrame.moveableBankCheck, "RIGHT", 5, 0)
    configFrame.moveableBankCheck.text:SetText("Make bank moveable")
    configFrame.moveableBankCheck:SetChecked(self:GetSetting("moveableBank"))
    configFrame.moveableBankCheck:SetScript("OnClick", function(self)
        Config:SetSetting("moveableBank", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:CreateTargetClassIconCheckbox(yOffset, x)
    configFrame.targetClassIconCheck = CreateFrame("CheckButton", "ForeverTunedConfigTargetClassIcon", configFrame, "UICheckButtonTemplate")
    configFrame.targetClassIconCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.targetClassIconCheck.text = configFrame.targetClassIconCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.targetClassIconCheck.text:SetPoint("LEFT", configFrame.targetClassIconCheck, "RIGHT", 5, 0)
    configFrame.targetClassIconCheck.text:SetText("Show target player's class icon")
    configFrame.targetClassIconCheck:SetChecked(self:GetSetting("showTargetClassIcon"))
    configFrame.targetClassIconCheck:SetScript("OnClick", function(self)
        Config:SetSetting("showTargetClassIcon", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:CreateNameplateLevelCheckbox(yOffset, x)
    configFrame.nameplateLevelCheck = CreateFrame("CheckButton", "ForeverTunedConfigNameplateLevel", configFrame, "UICheckButtonTemplate")
    configFrame.nameplateLevelCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.nameplateLevelCheck.text = configFrame.nameplateLevelCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.nameplateLevelCheck.text:SetPoint("LEFT", configFrame.nameplateLevelCheck, "RIGHT", 5, 0)
    configFrame.nameplateLevelCheck.text:SetText("Show level on the left side")
    configFrame.nameplateLevelCheck:SetChecked(self:GetSetting("nameplateLevelOnLeft"))
    configFrame.nameplateLevelCheck:SetScript("OnClick", function(self)
        Config:SetSetting("nameplateLevelOnLeft", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:CreateCharacterTabsCheckbox(yOffset, x)
    configFrame.characterTabsCheck = CreateFrame("CheckButton", "ForeverTunedConfigCharacterTabs", configFrame, "UICheckButtonTemplate")
    configFrame.characterTabsCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.characterTabsCheck.text = configFrame.characterTabsCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.characterTabsCheck.text:SetPoint("LEFT", configFrame.characterTabsCheck, "RIGHT", 5, 0)
    configFrame.characterTabsCheck.text:SetText("Move tabs to the bottom")
    configFrame.characterTabsCheck:SetChecked(self:GetSetting("characterTabsAtBottom"))
    configFrame.characterTabsCheck:SetScript("OnClick", function(self)
        Config:SetSetting("characterTabsAtBottom", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
        Config:UpdateCharacterTabsTextModeState()
    end)
    return yOffset - 30
end

function Config:UpdateCharacterTabsTextModeState()
    if not configFrame.characterTabsTextModeCheck then return end
    if self:GetSetting("characterTabsAtBottom") then
        configFrame.characterTabsTextModeCheck:Enable()
        configFrame.characterTabsTextModeCheck.text:SetTextColor(1, 0.82, 0)
    else
        configFrame.characterTabsTextModeCheck:Disable()
        configFrame.characterTabsTextModeCheck.text:SetTextColor(0.5, 0.5, 0.5)
    end
end

function Config:CreateCharacterTabsTextModeCheckbox(yOffset, x)
    configFrame.characterTabsTextModeCheck = CreateFrame("CheckButton", "ForeverTunedConfigCharacterTabsTextMode", configFrame, "UICheckButtonTemplate")
    configFrame.characterTabsTextModeCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x + 20, yOffset)
    configFrame.characterTabsTextModeCheck.text = configFrame.characterTabsTextModeCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.characterTabsTextModeCheck.text:SetPoint("LEFT", configFrame.characterTabsTextModeCheck, "RIGHT", 5, 0)
    configFrame.characterTabsTextModeCheck.text:SetText("Use text labels (classic style)")
    configFrame.characterTabsTextModeCheck:SetChecked(self:GetSetting("characterTabsTextMode"))
    configFrame.characterTabsTextModeCheck:SetScript("OnClick", function(self)
        Config:SetSetting("characterTabsTextMode", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    self:UpdateCharacterTabsTextModeState()
    return yOffset - 30
end

function Config:CreateDisableAutoGearCompareCheckbox(yOffset, x)
    configFrame.disableAutoGearCompareCheck = CreateFrame("CheckButton", "ForeverTunedConfigDisableAutoGearCompare", configFrame, "UICheckButtonTemplate")
    configFrame.disableAutoGearCompareCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.disableAutoGearCompareCheck.text = configFrame.disableAutoGearCompareCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.disableAutoGearCompareCheck.text:SetPoint("LEFT", configFrame.disableAutoGearCompareCheck, "RIGHT", 5, 0)
    configFrame.disableAutoGearCompareCheck.text:SetText("Do not auto compare gear upgrades")
    configFrame.disableAutoGearCompareCheck:SetChecked(self:GetSetting("disableAutoGearCompare"))
    configFrame.disableAutoGearCompareCheck:SetScript("OnClick", function(self)
        Config:SetSetting("disableAutoGearCompare", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:ShowUI()
    if configFrame then
        settingsChanged = false
        originalSettings = {
            moveableCombinedBag = self:GetSetting("moveableCombinedBag"),
            moveableBank = self:GetSetting("moveableBank"),
            showTargetClassIcon = self:GetSetting("showTargetClassIcon"),
            nameplateLevelOnLeft = self:GetSetting("nameplateLevelOnLeft"),
            characterTabsAtBottom = self:GetSetting("characterTabsAtBottom"),
            characterTabsTextMode = self:GetSetting("characterTabsTextMode"),
            disableAutoGearCompare = self:GetSetting("disableAutoGearCompare"),
            redIconOutOfRange = self:GetSetting("redIconOutOfRange"),
        }
        if configFrame.reloadButton then
            configFrame.reloadButton:Disable()
        end
        if configFrame.moveableBagCheck then
            configFrame.moveableBagCheck:SetChecked(self:GetSetting("moveableCombinedBag"))
        end
        if configFrame.moveableBankCheck then
            configFrame.moveableBankCheck:SetChecked(self:GetSetting("moveableBank"))
        end
        if configFrame.targetClassIconCheck then
            configFrame.targetClassIconCheck:SetChecked(self:GetSetting("showTargetClassIcon"))
        end
        if configFrame.nameplateLevelCheck then
            configFrame.nameplateLevelCheck:SetChecked(self:GetSetting("nameplateLevelOnLeft"))
        end
        if configFrame.characterTabsCheck then
            configFrame.characterTabsCheck:SetChecked(self:GetSetting("characterTabsAtBottom"))
        end
        if configFrame.characterTabsTextModeCheck then
            configFrame.characterTabsTextModeCheck:SetChecked(self:GetSetting("characterTabsTextMode"))
        end
        self:UpdateCharacterTabsTextModeState()
        if configFrame.disableAutoGearCompareCheck then
            configFrame.disableAutoGearCompareCheck:SetChecked(self:GetSetting("disableAutoGearCompare"))
        end
        if configFrame.redIconOutOfRangeCheck then
            configFrame.redIconOutOfRangeCheck:SetChecked(self:GetSetting("redIconOutOfRange"))
        end
        configFrame:Show()
    end
end

function Config:CreateRedIconOutOfRangeCheckbox(yOffset, x)
    configFrame.redIconOutOfRangeCheck = CreateFrame("CheckButton", "ForeverTunedConfigRedIconOutOfRange", configFrame, "UICheckButtonTemplate")
    configFrame.redIconOutOfRangeCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", x, yOffset)
    configFrame.redIconOutOfRangeCheck.text = configFrame.redIconOutOfRangeCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.redIconOutOfRangeCheck.text:SetPoint("LEFT", configFrame.redIconOutOfRangeCheck, "RIGHT", 5, 0)
    configFrame.redIconOutOfRangeCheck.text:SetText("Red icon when out of range")
    configFrame.redIconOutOfRangeCheck:SetChecked(self:GetSetting("redIconOutOfRange"))
    configFrame.redIconOutOfRangeCheck:SetScript("OnClick", function(self)
        Config:SetSetting("redIconOutOfRange", self:GetChecked())
        settingsChanged = true
        if configFrame.reloadButton then
            configFrame.reloadButton:Enable()
        end
    end)
    return yOffset - 30
end

function Config:RegisterSlashCommand()
    SLASH_FOREVERTWEAKS1 = "/forevertweaks"
    SLASH_FOREVERTWEAKS2 = "/ft"
    SlashCmdList["FOREVERTWEAKS"] = function(msg)
        Config:ShowUI()
    end
end

function Config:CreateMinimapButton()
    minimapButton = CreateFrame("Button", "ForeverTunedMinimapButton", Minimap)
    minimapButton:SetSize(31, 31)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER", 0, 1)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")

    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    minimapButton:SetScript("OnClick", function()
        Config:ShowUI()
    end)

    minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("ForeverTuned")
        GameTooltip:AddLine("Click to open settings", 1, 1, 1)
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    ForeverTunedDB.minimapAngle = ForeverTunedDB.minimapAngle or 45
    self:UpdateMinimapPosition()

    minimapButton:RegisterForDrag("LeftButton")
    minimapButton:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", Config.OnMinimapDrag)
    end)
    minimapButton:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)
end

function Config.OnMinimapDrag()
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale()
    px, py = px / scale, py / scale

    local angle = math.deg(math.atan2(py - my, px - mx))
    ForeverTunedDB.minimapAngle = angle
    Config:UpdateMinimapPosition()
end

function Config:UpdateMinimapPosition()
    local angle = math.rad(ForeverTunedDB.minimapAngle or 45)
    local x = math.cos(angle) * 110
    local y = math.sin(angle) * 110
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

