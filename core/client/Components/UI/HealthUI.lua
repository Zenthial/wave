local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local wcs = require(ReplicatedStorage.Shared.wcs)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local HealthUI = {}
HealthUI.__index = HealthUI
HealthUI.Name = "HealthUI"
HealthUI.Tag = "HealthUI"
HealthUI.Needs = {"Cleaner"}
HealthUI.Ancestor = PlayerGui

--[[
    Health UI structure
    Container: Root
    Health
    Fill1 Fill2
    Gradient under each
]]

function HealthUI.new(root: any)
    return setmetatable({
        Root = root,
    }, HealthUI)
end

function HealthUI:Start()
    local maxShields = Player:GetAttribute("MaxHealth")

    self.Root.Health.Fill.UIGradient.Offset = Vector2.new(-0.5, 0)
    self.Root.Health.Fill2.UIGradient.Offset = Vector2.new(0.5, 0)

    local shieldsChangedSignal = Player:GetAttributeChangedSignal("Health")
    self.Cleaner:Add(shieldsChangedSignal:Connect(function()
        local currentShieldsValue = Player:GetAttribute("Health")
        local tweenValue = (currentShieldsValue/maxShields) - 0.5 -- subtract 0.5 cause the gradient goes from -0.5 to 0.5 rather than 0 to 1
        TweenService:Create(self.Root.Health.Fill.UIGradient, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(-tweenValue, 0)}):Play()
        TweenService:Create(self.Root.Health.Fill2.UIGradient, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(tweenValue, 0)}):Play()
    end))
end

function HealthUI:Destroy()
    self.Cleaner:Clean()
end

wcs.create_component(HealthUI)

return HealthUI