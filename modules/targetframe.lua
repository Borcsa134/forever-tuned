local TargetFrameModule = {}
ForeverTuned.modules.TargetFrame = TargetFrameModule

local classIcon
local iconFrame
local border

function TargetFrameModule:Initialize()
    self:CreateClassIcon()
    self:RegisterEvents()
end

function TargetFrameModule:CreateClassIcon()
    if classIcon then return end

    iconFrame = CreateFrame("Frame", nil, TargetFrame)
    iconFrame:SetSize(48, 48)
    iconFrame:SetPoint("TOPRIGHT", TargetFrame, "TOPRIGHT", 5, -10)

    classIcon = iconFrame:CreateTexture(nil, "ARTWORK")
    classIcon:SetSize(24, 24)
    classIcon:SetPoint("CENTER", -10, 12)
    classIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")

    border = iconFrame:CreateTexture(nil, "OVERLAY")
    border:SetSize(60, 60)
    border:SetPoint("CENTER", 0, 0)
    border:SetTexture("Interface\\Minimap\\Minimap-TrackingBorder")
    border:SetVertexColor(1, 1, 1, 1)

    iconFrame:Hide()
end

function TargetFrameModule:RegisterEvents()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    frame:SetScript("OnEvent", function(self, event)
        TargetFrameModule:UpdateClassIcon()
    end)
end

function TargetFrameModule:UpdateClassIcon()
    if not ForeverTunedDB.settings.showTargetClassIcon then
        iconFrame:Hide()
        return
    end

    if not UnitExists("target") then
        iconFrame:Hide()
        return
    end

    local _, class = UnitClass("target")

    if not class or UnitIsPlayer("target") == false then
        iconFrame:Hide()
        return
    end

    local coords = CLASS_ICON_TCOORDS[class]
    if coords then
        classIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        iconFrame:Show()
    else
        iconFrame:Hide()
    end
end

function TargetFrameModule:OnLogout()
end
