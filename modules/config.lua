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
end

function Config:GetSetting(key)
    return ForeverTunedDB.settings[key]
end

function Config:SetSetting(key, value)
    ForeverTunedDB.settings[key] = value
end

function Config:CreateUI()
    configFrame = CreateFrame("Frame", "ForeverTunedConfigFrame", UIParent, "PortraitFrameTemplate")
    configFrame:SetSize(400, 300)
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
            Config:SetSetting("showTargetClassIcon", originalSettings.showTargetClassIcon)
            Config:SetSetting("nameplateLevelOnLeft", originalSettings.nameplateLevelOnLeft)
            settingsChanged = false
        end
        configFrame:Hide()
    end)

    local yOffset = -70

    local bagsHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bagsHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    bagsHeader:SetText("Bags")
    yOffset = yOffset - 30

    yOffset = self:CreateMoveableBagCheckbox(yOffset)

    yOffset = yOffset - 10

    local targetHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    targetHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    targetHeader:SetText("Target Frame")
    yOffset = yOffset - 30

    yOffset = self:CreateTargetClassIconCheckbox(yOffset)

    yOffset = yOffset - 10

    local nameplatesHeader = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nameplatesHeader:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    nameplatesHeader:SetText("Nameplates")
    yOffset = yOffset - 30

    yOffset = self:CreateNameplateLevelCheckbox(yOffset)

    configFrame.closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configFrame.closeButton:SetSize(80, 22)
    configFrame.closeButton:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -10, 10)
    configFrame.closeButton:SetText("Close")
    configFrame.closeButton:SetScript("OnClick", function()
        if settingsChanged then
            Config:SetSetting("moveableCombinedBag", originalSettings.moveableCombinedBag)
            Config:SetSetting("showTargetClassIcon", originalSettings.showTargetClassIcon)
            Config:SetSetting("nameplateLevelOnLeft", originalSettings.nameplateLevelOnLeft)
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

function Config:CreateMoveableBagCheckbox(yOffset)
    configFrame.moveableBagCheck = CreateFrame("CheckButton", "ForeverTunedConfigMoveableBag", configFrame, "UICheckButtonTemplate")
    configFrame.moveableBagCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    configFrame.moveableBagCheck.text = configFrame.moveableBagCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.moveableBagCheck.text:SetPoint("LEFT", configFrame.moveableBagCheck, "RIGHT", 5, 0)
    configFrame.moveableBagCheck.text:SetText("Moveable Combined Bag")
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

function Config:CreateTargetClassIconCheckbox(yOffset)
    configFrame.targetClassIconCheck = CreateFrame("CheckButton", "ForeverTunedConfigTargetClassIcon", configFrame, "UICheckButtonTemplate")
    configFrame.targetClassIconCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    configFrame.targetClassIconCheck.text = configFrame.targetClassIconCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.targetClassIconCheck.text:SetPoint("LEFT", configFrame.targetClassIconCheck, "RIGHT", 5, 0)
    configFrame.targetClassIconCheck.text:SetText("Show Target Class Icon")
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

function Config:CreateNameplateLevelCheckbox(yOffset)
    configFrame.nameplateLevelCheck = CreateFrame("CheckButton", "ForeverTunedConfigNameplateLevel", configFrame, "UICheckButtonTemplate")
    configFrame.nameplateLevelCheck:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, yOffset)
    configFrame.nameplateLevelCheck.text = configFrame.nameplateLevelCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    configFrame.nameplateLevelCheck.text:SetPoint("LEFT", configFrame.nameplateLevelCheck, "RIGHT", 5, 0)
    configFrame.nameplateLevelCheck.text:SetText("Show Level on Left Side")
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

function Config:ShowUI()
    if configFrame then
        settingsChanged = false
        originalSettings = {
            moveableCombinedBag = self:GetSetting("moveableCombinedBag"),
            showTargetClassIcon = self:GetSetting("showTargetClassIcon"),
            nameplateLevelOnLeft = self:GetSetting("nameplateLevelOnLeft")
        }
        if configFrame.reloadButton then
            configFrame.reloadButton:Disable()
        end
        if configFrame.moveableBagCheck then
            configFrame.moveableBagCheck:SetChecked(self:GetSetting("moveableCombinedBag"))
        end
        if configFrame.targetClassIconCheck then
            configFrame.targetClassIconCheck:SetChecked(self:GetSetting("showTargetClassIcon"))
        end
        if configFrame.nameplateLevelCheck then
            configFrame.nameplateLevelCheck:SetChecked(self:GetSetting("nameplateLevelOnLeft"))
        end
        configFrame:Show()
    end
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

