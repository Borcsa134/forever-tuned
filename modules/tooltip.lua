local TooltipModule = {}
ForeverTuned.modules.Tooltip = TooltipModule

function TooltipModule:Initialize()
    self:DisableAutoGearCompare()
end

function TooltipModule:DisableAutoGearCompare()
    hooksecurefunc("GameTooltip_ShowCompareItem", function(self, anchorFrame)
        if not ForeverTuned.modules.Config:GetSetting("disableAutoGearCompare") then
            return
        end

        if not IsShiftKeyDown() then
            ShoppingTooltip1:Hide()
            ShoppingTooltip2:Hide()
        end
    end)
end

function TooltipModule:OnLogout()
end
