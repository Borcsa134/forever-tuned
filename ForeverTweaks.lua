-- ForeverTweaks: Basic addon for WoW Forever
local addonName = "ForeverTweaks"
local addonVersion = "1.0.0"

-- Event frame to handle addon loading
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        print(addonName .. " v" .. addonVersion .. " loaded successfully!")
    end
end)
