local addonName = "ForeverTuned"
local addonVersion = "1.0.1"

ForeverTuned = ForeverTuned or {}
ForeverTuned.modules = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        ForeverTunedDB = ForeverTunedDB or {}
        ForeverTunedDB.settings = ForeverTunedDB.settings or {}

        if ForeverTuned.modules.Config then
            ForeverTuned.modules.Config:Initialize()
        end

        for name, module in pairs(ForeverTuned.modules) do
            if module.Initialize and name ~= "Config" then
                module:Initialize()
            end
        end
    elseif event == "PLAYER_LOGOUT" then
        for name, module in pairs(ForeverTuned.modules) do
            if module.OnLogout then
                module:OnLogout()
            end
        end
    end
end)
