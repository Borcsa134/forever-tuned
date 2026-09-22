local Config = {}
ForeverTweaks.modules.Config = Config

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
    if ForeverTweaksDB.settings.moveableCombinedBag == nil then
        ForeverTweaksDB.settings.moveableCombinedBag = true
    end
end

function Config:GetSetting(key)
    return ForeverTweaksDB.settings[key]
end

function Config:SetSetting(key, value)
    ForeverTweaksDB.settings[key] = value
end

function Config:CreateUI()
    configFrame = CreateFrame("Frame", "ForeverTweaksConfigFrame", UIParent, "PortraitFrameTemplate")
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
    configFrame.title:SetText("ForeverTweaks Settings")
    configFrame.title:SetTextColor(1, 0.82, 0)

    configFrame.CloseButton:SetScript("OnClick", function()
        if settingsChanged then
            Config:SetSetting("moveableCombinedBag", originalSettings.moveableCombinedBag)
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

    configFrame.closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    configFrame.closeButton:SetSize(80, 22)
    configFrame.closeButton:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -10, 10)
    configFrame.closeButton:SetText("Close")
    configFrame.closeButton:SetScript("OnClick", function()
        if settingsChanged then
            Config:SetSetting("moveableCombinedBag", originalSettings.moveableCombinedBag)
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
    configFrame.moveableBagCheck = CreateFrame("CheckButton", "ForeverTweaksConfigMoveableBag", configFrame, "UICheckButtonTemplate")
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

function Config:ShowUI()
    if configFrame then
        settingsChanged = false
        originalSettings = {
            moveableCombinedBag = self:GetSetting("moveableCombinedBag")
        }
        if configFrame.reloadButton then
            configFrame.reloadButton:Disable()
        end
        if configFrame.moveableBagCheck then
            configFrame.moveableBagCheck:SetChecked(self:GetSetting("moveableCombinedBag"))
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
    minimapButton = CreateFrame("Button", "ForeverTweaksMinimapButton", Minimap)
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
        GameTooltip:AddLine("ForeverTweaks")
        GameTooltip:AddLine("Click to open settings", 1, 1, 1)
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    ForeverTweaksDB.minimapAngle = ForeverTweaksDB.minimapAngle or 45
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
    ForeverTweaksDB.minimapAngle = angle
    Config:UpdateMinimapPosition()
end

function Config:UpdateMinimapPosition()
    local angle = math.rad(ForeverTweaksDB.minimapAngle or 45)
    local x = math.cos(angle) * 110
    local y = math.sin(angle) * 110
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

