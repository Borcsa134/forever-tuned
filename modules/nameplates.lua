local NamePlates = {}
ForeverTuned.modules.NamePlates = NamePlates

function NamePlates:Initialize()
    self:MoveLevelToLeft()
end

function NamePlates:MoveLevelToLeft()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    frame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    frame:SetScript("OnEvent", function(self, event, unitToken)
        if event == "NAME_PLATE_UNIT_ADDED" then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unitToken)
            if nameplate then
                NamePlates:AdjustNamePlate(nameplate)
            end
        end
    end)

    for _, nameplate in pairs(C_NamePlate.GetNamePlates()) do
        self:AdjustNamePlate(nameplate)
    end
end

function NamePlates:AdjustNamePlate(nameplate)
    if not nameplate or not nameplate.UnitFrame then
        return
    end

    if not ForeverTunedDB.settings.nameplateLevelOnLeft then
        return
    end

    local healthBar = nameplate.UnitFrame.healthBar or nameplate.UnitFrame.HealthBar
    local levelDiffFrame = nameplate.UnitFrame.PlayerLevelDiffFrame

    if levelDiffFrame and healthBar and not levelDiffFrame.foreverTunedMoved then
        levelDiffFrame:ClearAllPoints()
        levelDiffFrame:SetPoint("RIGHT", healthBar, "LEFT", -2, 0)
        levelDiffFrame.foreverTunedMoved = true
    end
end

function NamePlates:OnLogout()
end
