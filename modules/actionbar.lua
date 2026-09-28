local ActionBar = {}
ForeverTuned.modules.ActionBar = ActionBar

local RANGE_COLOR = {1, 0.2, 0.2}

local BAR_BUTTONS = {
    {prefix = "ActionButton",              slots = 1},
    {prefix = "MultiBarBottomLeftButton",  slots = 61},
    {prefix = "MultiBarBottomRightButton", slots = 49},
    {prefix = "MultiBarRightButton",       slots = 25},
    {prefix = "MultiBarLeftButton",        slots = 37},
    {prefix = "MultiBar5Button",           slots = 145},
    {prefix = "MultiBar6Button",           slots = 157},
    {prefix = "MultiBar7Button",           slots = 169},
}

local trackedButtons = {}

local function CollectButtons()
    for _, bar in ipairs(BAR_BUTTONS) do
        for i = 1, 12 do
            local btn = _G[bar.prefix .. i]
            if btn then
                trackedButtons[btn] = bar.slots + i - 1
            end
        end
    end
end

local function UpdateButtonColor(btn, slot)
    local icon = btn.icon or btn.Icon
    if not icon then return end

    if C_ActionBar.IsActionInRange(slot) == false then
        icon:SetVertexColor(RANGE_COLOR[1], RANGE_COLOR[2], RANGE_COLOR[3])
    else
        if btn.ftOutOfRange then
            icon:SetVertexColor(1, 1, 1)
        end
        btn.ftOutOfRange = nil
        return
    end

    btn.ftOutOfRange = true
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
        for btn, slot in pairs(trackedButtons) do
            UpdateButtonColor(btn, slot)
        end
    end)

end

function ActionBar:OnLogout()
end
