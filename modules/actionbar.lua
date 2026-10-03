local ActionBar = {}
ForeverTuned.modules.ActionBar = ActionBar

local RANGE_COLOR = {1, 0.2, 0.2}

local BAR_PREFIXES = {
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
    "MultiBar5Button",
    "MultiBar6Button",
    "MultiBar7Button",
}

local trackedButtons = {}

local function CollectButtons()
    for _, prefix in ipairs(BAR_PREFIXES) do
        for i = 1, 12 do
            local btn = _G[prefix .. i]
            if btn then
                trackedButtons[#trackedButtons + 1] = btn
            end
        end
    end
end

local function GetButtonAction(btn)
    local slot = btn.action
    if not slot then
        slot = btn:GetAttribute("action")
    end
    return slot
end

local function RestoreNormalColor(btn, slot)
    local icon = btn.icon or btn.Icon
    if not icon then return end
    local isUsable, notEnoughMana = IsUsableAction(slot)
    if isUsable then
        icon:SetVertexColor(1.0, 1.0, 1.0)
    elseif notEnoughMana then
        icon:SetVertexColor(0.5, 0.5, 1.0)
    else
        icon:SetVertexColor(0.4, 0.4, 0.4)
    end
end

local function UpdateButton(btn)
    local slot = GetButtonAction(btn)
    if not slot or not HasAction(slot) then
        btn.ftOutOfRange = nil
        return
    end

    local inRange = C_ActionBar.IsActionInRange(slot)

    if inRange == false then
        if not btn.ftOutOfRange then
            local icon = btn.icon or btn.Icon
            if icon then
                icon:SetVertexColor(RANGE_COLOR[1], RANGE_COLOR[2], RANGE_COLOR[3])
            end
            btn.ftOutOfRange = true
        end
    else
        if btn.ftOutOfRange then
            RestoreNormalColor(btn, slot)
            btn.ftOutOfRange = nil
        end
    end
end

local POLL_INTERVAL = 0.1
local elapsed = 0

function ActionBar:Initialize()
    if not ForeverTuned.modules.Config:GetSetting("redIconOutOfRange") then return end

    CollectButtons()

    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(self, e)
        elapsed = elapsed + e
        if elapsed < POLL_INTERVAL then return end
        elapsed = 0
        for _, btn in ipairs(trackedButtons) do
            UpdateButton(btn)
        end
    end)
end

function ActionBar:OnLogout()
end
