local Bags = {}
ForeverTuned.modules.Bags = Bags

function Bags:Initialize()
    ForeverTunedDB.Bags = ForeverTunedDB.Bags or {}

    if ForeverTuned.modules.Config:GetSetting("moveableCombinedBag") then
        self:MakeCombinedBagMoveable()
        self:AnchorReagentBag()
    end
end

function Bags:OnLogout()
    self:SavePosition()
end

function Bags:SavePosition()
    if ContainerFrameCombinedBags then
        local point, _, relativePoint, xOfs, yOfs = ContainerFrameCombinedBags:GetPoint()
        ForeverTunedDB.Bags.CombinedBagPosition = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs
        }
    end
end

function Bags:MakeCombinedBagMoveable()
    local isSetting = false

    local function applyPosition()
        if not ForeverTunedDB.Bags.CombinedBagPosition then return end
        local pos = ForeverTunedDB.Bags.CombinedBagPosition
        isSetting = true
        ContainerFrameCombinedBags:ClearAllPoints()
        ContainerFrameCombinedBags:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        isSetting = false
    end

    local function setupMoveable()
        if ContainerFrameCombinedBags then
            ContainerFrameCombinedBags:SetMovable(true)
            ContainerFrameCombinedBags:EnableMouse(true)
            ContainerFrameCombinedBags:RegisterForDrag("LeftButton")

            ContainerFrameCombinedBags:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)

            ContainerFrameCombinedBags:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
                Bags:SavePosition()
            end)

            hooksecurefunc(ContainerFrameCombinedBags, "SetPoint", function()
                if not isSetting and ForeverTunedDB.Bags.CombinedBagPosition then
                    local ticker = CreateFrame("Frame")
                    ticker:SetScript("OnUpdate", function(self)
                        self:SetScript("OnUpdate", nil)
                        applyPosition()
                    end)
                end
            end)

            applyPosition()

            return true
        end
        return false
    end

    if not setupMoveable() then
        local waitFrame = CreateFrame("Frame")
        waitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        waitFrame:SetScript("OnEvent", function(self, event)
            if setupMoveable() then
                self:UnregisterAllEvents()
            end
        end)
    end
end

function Bags:AnchorReagentBag()
    local function anchorDeferred()
        local ticker = CreateFrame("Frame")
        ticker:SetScript("OnUpdate", function(self)
            self:SetScript("OnUpdate", nil)
            if ContainerFrame6:IsShown() and ContainerFrameCombinedBags:IsShown() then
                ContainerFrame6:ClearAllPoints()
                ContainerFrame6:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -5, 0)
            end
        end)
    end

    local function setupReagentBag()
        if ContainerFrame6 and ContainerFrameCombinedBags then
            hooksecurefunc(ContainerFrame6, "Show", function()
                anchorDeferred()
            end)

            hooksecurefunc(ContainerFrameCombinedBags, "Show", function()
                if ContainerFrame6:IsShown() then
                    anchorDeferred()
                end
            end)

            if ContainerFrame6:IsShown() and ContainerFrameCombinedBags:IsShown() then
                anchorDeferred()
            end

            return true
        end
        return false
    end

    if not setupReagentBag() then
        local waitFrame = CreateFrame("Frame")
        waitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        waitFrame:SetScript("OnEvent", function(self, event)
            if setupReagentBag() then
                self:UnregisterAllEvents()
            end
        end)
    end
end
