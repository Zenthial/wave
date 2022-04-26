local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage.Shared.tcs)

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
    local maxHealth = Player:GetAttribute("MaxHealth")

    self.Root.Health.Fill.UIGradient.Offset = Vector2.new(-0.5, 0)
    self.Root.Health.Fill2.UIGradient.Offset = Vector2.new(0.5, 0)

    local heathChangedSignal = Player:GetAttributeChangedSignal("Health")
    self.Cleaner:Add(heathChangedSignal:Connect(function()
        local currentHealth = Player:GetAttribute("Health")
        local tweenValue = (currentHealth/maxHealth) - 0.5 -- subtract 0.5 cause the gradient goes from -0.5 to 0.5 rather than 0 to 1
        TweenService:Create(self.Root.Health.Fill.UIGradient, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(-tweenValue, 0)}):Play()
        TweenService:Create(self.Root.Health.Fill2.UIGradient, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Offset = Vector2.new(tweenValue, 0)}):Play()

        if currentHealth < maxHealth * .30 then
            self.Root.Health.Fill.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 78, 96))
            self.Root.Health.Fill2.UIGradient.Color = ColorSequence.new(Color3.fromRGB(255, 78, 96))
        else
            self.Root.Health.Fill.UIGradient.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
            self.Root.Health.Fill2.UIGradient.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
        end
    end))
end

function HealthUI:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(HealthUI)

return HealthUI