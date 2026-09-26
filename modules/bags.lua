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
    local isRestoring = false

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

            ContainerFrameCombinedBags:HookScript("OnShow", function(self)
                if not isRestoring and ForeverTunedDB.Bags.CombinedBagPosition then
                    isRestoring = true
                    local pos = ForeverTunedDB.Bags.CombinedBagPosition
                    self:Hide()

                    local frame = CreateFrame("Frame")
                    frame:SetScript("OnUpdate", function(self)
                        ContainerFrameCombinedBags:ClearAllPoints()
                        ContainerFrameCombinedBags:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
                        ContainerFrameCombinedBags:Show()

                        self:SetScript("OnUpdate", function(self)
                            isRestoring = false
                            self:SetScript("OnUpdate", nil)
                        end)
                    end)
                end
            end)

            if ForeverTunedDB.Bags.CombinedBagPosition then
                local pos = ForeverTunedDB.Bags.CombinedBagPosition
                ContainerFrameCombinedBags:ClearAllPoints()
                ContainerFrameCombinedBags:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
            end

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
    ToggleAllBags = function()
        if ContainerFrameCombinedBags and ContainerFrame6 then
            if ContainerFrameCombinedBags:IsShown() then
                CloseAllBags()
            else
                OpenAllBags()
            end
        end
    end

    local function setupReagentBag()
        if ContainerFrame6 and ContainerFrameCombinedBags then
            ContainerFrame6:ClearAllPoints()
            ContainerFrame6:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -5, 0)

            hooksecurefunc(ContainerFrame6, "Show", function()
                if ContainerFrameCombinedBags:IsShown() then
                    ContainerFrame6:ClearAllPoints()
                    ContainerFrame6:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -5, 0)
                else
                    OpenAllBags()
                end
            end)

            hooksecurefunc(ContainerFrameCombinedBags, "Show", function()
                if not ContainerFrame6:IsShown() then
                    OpenBag(5)
                end
                    ContainerFrame6:ClearAllPoints()
                    ContainerFrame6:SetPoint("TOPRIGHT", ContainerFrameCombinedBags, "TOPLEFT", -5, 0)
            end)

            hooksecurefunc(ContainerFrameCombinedBags, "Hide", function()
                if ContainerFrame6:IsShown() then
                    CloseBag(5)
                end
            end)

            hooksecurefunc(ContainerFrame6, "Hide", function()
                if ContainerFrameCombinedBags:IsShown() then
                    CloseAllBags()
                end
            end)

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
