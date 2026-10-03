local Bags = {}
ForeverTuned.modules.Bags = Bags

function Bags:Initialize()
    ForeverTunedDB.Bags = ForeverTunedDB.Bags or {}

    if ForeverTuned.modules.Config:GetSetting("moveableCombinedBag") then
        self:MakeCombinedBagMoveable()
        self:AnchorReagentBag()
        self:OverrideBagKeybind()
    end

    if ForeverTuned.modules.Config:GetSetting("moveableBank") then
        self:MakeBankMoveable()
    end
end

function Bags:OnLogout()
    self:SaveBagPosition()
    self:SaveBankPosition()
end

function Bags:SaveBankPosition()
    if BankFrame and BankFrame:IsShown() then
        local point, _, relativePoint, xOfs, yOfs = BankFrame:GetPoint()
        ForeverTunedDB.Bags.BankPosition = {
            point = point,
            relativePoint = relativePoint,
            xOfs = xOfs,
            yOfs = yOfs
        }
    end
end

function Bags:MakeBankMoveable()
    local isSetting = false

    local function applyPosition()
        if not ForeverTunedDB.Bags.BankPosition then return end
        local pos = ForeverTunedDB.Bags.BankPosition
        isSetting = true
        BankFrame:ClearAllPoints()
        BankFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
        isSetting = false
    end

    local function setupMoveable()
        if BankFrame then
            BankFrame:SetMovable(true)
            BankFrame:EnableMouse(true)
            BankFrame:RegisterForDrag("LeftButton")

            BankFrame:SetScript("OnDragStart", function(self)
                self:StartMoving()
            end)

            BankFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
                Bags:SaveBankPosition()
            end)

            hooksecurefunc(BankFrame, "SetPoint", function()
                if not isSetting and ForeverTunedDB.Bags.BankPosition then
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

function Bags:SaveBagPosition()
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
                Bags:SaveBagPosition()
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

function Bags:OverrideBagKeybind()
    local function applyBinding()
        if InCombatLockdown() then return false end

        local key1, key2 = GetBindingKey("TOGGLEBACKPACK")
        if not key1 and not key2 then return true end

        if key1 then SetBinding(key1, "OPENALLBAGS") end
        if key2 then SetBinding(key2, "OPENALLBAGS") end

        SaveBindings(GetCurrentBindingSet())
        return true
    end

    local waitFrame = CreateFrame("Frame")
    waitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    waitFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    waitFrame:SetScript("OnEvent", function(self, event)
        if applyBinding() then
            self:UnregisterAllEvents()
        end
    end)
end
