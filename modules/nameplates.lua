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

    local unitFrame = nameplate.UnitFrame
    local healthBar = unitFrame.healthBar or unitFrame.HealthBar
    local levelDiffFrame = unitFrame.PlayerLevelDiffFrame

    if levelDiffFrame and healthBar and not levelDiffFrame.foreverTunedMoved then
        levelDiffFrame:ClearAllPoints()
        levelDiffFrame:SetPoint("RIGHT", healthBar, "LEFT", -2, 0)
        levelDiffFrame.foreverTunedMoved = true
    end

    if unitFrame.UpdateControlAnchors and not unitFrame.foreverTunedControlHook then
        unitFrame.foreverTunedControlHook = true
        hooksecurefunc(unitFrame, "UpdateControlAnchors", function(self)
            local aurasFrame = self.AurasFrame
            local container = self.HealthBarsContainer
            if not aurasFrame or not container then
                return
            end

            local crowdControlListFrame = aurasFrame.CrowdControlListFrame
            local lossOfControlFrame = aurasFrame.LossOfControlFrame

            if crowdControlListFrame then
                crowdControlListFrame:ClearAllPoints()
                crowdControlListFrame:SetPoint("LEFT", container, "RIGHT", 5, 0)
            end
            if lossOfControlFrame then
                lossOfControlFrame:ClearAllPoints()
                lossOfControlFrame:SetPoint("LEFT", container, "RIGHT", 5, 0)
            end
        end)
    end
end

function NamePlates:OnLogout()
end
