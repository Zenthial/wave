local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local MAX_HEAT = 100

local TWEEN_CONSTANTS = {
    ChargeBarFillInfo = TweenInfo.new(.02, Enum.EasingStyle.Linear),
    ChargeBarFillSize = Vector2.new(-0.5, 0),
    ChargeBarEmptySize = Vector2.new(0.5, 0),

    HeatTweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear)
}

local HeatUI = {}
HeatUI.__index = HeatUI
HeatUI.Tag = "HeatUI"

--[[
    UI Structure
    ChargeDelay
        Fill
            UIGradient
    HeatOutline
        Heat
            Fill
                UIGradient
    Keybind
    NameDisplay
]]

function HeatUI.new(root: any)
    return setmetatable({
        Root = root,
        ChargeDelay = root.ChargeDelay,
        HeatOutline = root.HeatOutline,
        Keybind = root.Keybind,
        NameDisplay = root.NameDisplay,

        Cleaner = Trove.new()
    }, HeatUI)
end

function HeatUI:Initial()
    self.HeatOutline.Heat.Fill.UIGradient.Offset = Vector2.new(0.5, 0)
    self.ChargeDelay.Fill.UIGradient.Offset = Vector2.new(0.5, 0)
    self.NameDisplay.Text = "<i>--</i>"
end

function HeatUI:SetHeat(heat: number)
    local goal = (heat/MAX_HEAT) - .5
    TweenService:Create(self.HeatOutline.Heat.Fill.UIGradient, TWEEN_CONSTANTS.HeatTweenInfo, {Offset = Vector2.new(goal, 0)}):Play()
end

function HeatUI:TriggerBar(triggerTime: number)
    local outTween = TweenService:Create(self.ChargeDelay.Fill.UIGradient, TWEEN_CONSTANTS.ChargeBarFillInfo, {Offset = TWEEN_CONSTANTS.ChargeBarFillSize})
    outTween:Play()
    outTween.Completed:Connect(function()
        TweenService:Create(self.ChargeDelay.Fill.UIGradient, TweenInfo.new(triggerTime, Enum.EasingStyle.Linear), {Offset = TWEEN_CONSTANTS.ChargeBarEmptySize}):Play()
    end)
end

function HeatUI:SetKeybind(keybind: string)
    self.Keybind.Text = string.format("<i>%s</i>", keybind)
end

function HeatUI:SetName(name: string)
    if name == nil then
        self.NameDisplay.Text = "<i>--</i>"
    else
        self.NameDisplay.Text = string.format("<i>%s</i>", name)
    end
end

function HeatUI:Destroy()
    self.Cleaner:Clean()
end

Rosyn.Register("HeatUI", {HeatUI})

return HeatUI