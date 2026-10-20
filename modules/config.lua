local Config = {}
ForeverTuned.modules.Config = Config

function Config:Initialize()
    self:SetDefaults()
    self:CreateSettingsPanel()
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
    if ForeverTunedDB.settings.professionsTabsAtBottom == nil then
        ForeverTunedDB.settings.professionsTabsAtBottom = true
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

local GROUPS = {
    { header = "Bags", items = {
        { key = "moveableCombinedBag", label = "Make combined bag moveable" },
        { key = "moveableBank",        label = "Make bank moveable" },
    }},
    { header = "Target Frame", items = {
        { key = "showTargetClassIcon", label = "Show target player's class icon" },
    }},
    { header = "Nameplates", items = {
        { key = "nameplateLevelOnLeft", label = "Show level on the left side" },
    }},
    { header = "Character Frame", items = {
        { key = "characterTabsAtBottom", label = "Move tabs to the bottom" },
    }},
    { header = "Professions", items = {
        { key = "professionsTabsAtBottom", label = "Move tabs to the bottom" },
    }},
    { header = "Tooltips", items = {
        { key = "disableAutoGearCompare", label = "Do not auto compare gear upgrades", live = true },
    }},
    { header = "Action Bar", items = {
        { key = "redIconOutOfRange", label = "Red icon when out of range", live = true },
    }},
}

local RELOAD_MARK = " |cffff2020*|r"
local RELOAD_TOOLTIP = "|cffff2020*|r Requires a UI reload to take effect."

function Config:CreateSettingsPanel()
    local category, layout = Settings.RegisterVerticalLayoutCategory("Forever Tuned")
    self.categoryID = category:GetID()

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RELOAD_TOOLTIP))

    for _, group in ipairs(GROUPS) do
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(group.header))
        for _, item in ipairs(group.items) do
            local label = item.label
            if not item.live then
                label = label .. RELOAD_MARK
            end
            local setting = Settings.RegisterAddOnSetting(
                category,
                "ForeverTuned_" .. item.key,
                item.key,
                ForeverTunedDB.settings,
                Settings.VarType.Boolean,
                label,
                Settings.Default.True)
            if not item.live then
                setting:SetValueChangedCallback(function()
                    Config:PromptReload()
                end)
            end
            Settings.CreateCheckbox(category, setting, nil)
        end
    end

    Settings.RegisterAddOnCategory(category)
end

function Config:PromptReload()
    if not StaticPopupDialogs["FOREVERTUNED_RELOAD"] then
        StaticPopupDialogs["FOREVERTUNED_RELOAD"] = {
            text = "A UI reload is required to apply this change.",
            button1 = "Reload Now",
            button2 = "Later",
            OnAccept = function() ReloadUI() end,
            timeout = 0,
            whileDead = 1,
            hideOnEscape = 1,
        }
    end
    StaticPopup_Show("FOREVERTUNED_RELOAD")
end

function Config:ShowUI()
    if self.categoryID then
        Settings.OpenToCategory(self.categoryID)
    end
end

function Config:RegisterSlashCommand()
    SLASH_FOREVERTWEAKS1 = "/forevertweaks"
    SLASH_FOREVERTWEAKS2 = "/ft"
    SlashCmdList["FOREVERTWEAKS"] = function(msg)
        Config:ShowUI()
    end
end
