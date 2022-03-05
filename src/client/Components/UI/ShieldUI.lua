local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = Players.LocalPlayer

local ShieldUI = {}
ShieldUI.__index = ShieldUI

--[[
    Shield UI structure
    Container: Root
    Shield
    Fill1 Fill2
    Gradient under each
]]

function ShieldUI.new(root: any)
    return setmetatable({
        Root = root,

        Cleaner = Trove.new()
    }, ShieldUI)
end

function ShieldUI:Initial()
    local maxShields = Player:GetAttribute("MaxShields")

    local shieldsChangedSignal = Player:GetAttributeChangedSignal("Shields")
    self.Cleaner:Add(shieldsChangedSignal:Connect(function()
        local currentShieldsValue = Player:GetAttribute("Shields")
        local tweenValue = (currentShieldsValue/maxShields) - 0.5 -- subtract 0.5 cause the gradient goes from -0.5 to 0.5 rather than 0 to 1
        print(tweenValue)
        TweenService:Create(self.Root.Shield.Fill.UIGradient, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Offset = Vector2.new(-tweenValue, 0)}):Play()
        TweenService:Create(self.Root.Shield.Fill2.UIGradient, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {Offset = Vector2.new(tweenValue, 0)}):Play()
    end))
end

function ShieldUI:Destroy()
    self.Cleaner:Clean()
end

Rosyn.Register("ShieldUI", {ShieldUI})

return ShieldUI