local addonName = "ForeverTweaks"
local addonVersion = "1.0.0"

ForeverTweaks = ForeverTweaks or {}
ForeverTweaks.modules = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ForeverTweaksDB = ForeverTweaksDB or {}

        for name, module in pairs(ForeverTweaks.modules) do
            if module.Initialize then
                module:Initialize()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        for name, module in pairs(ForeverTweaks.modules) do
            if module.OnLogout then
                module:OnLogout()
            end
        end
    end
end)
