local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local SlaveClock = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Clock"))

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type Hans_T = {
    __index: Hans_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Hans: Hans_T = {}
Hans.__index = Hans
Hans.Name = "Hans"
Hans.Tag = "Hans"
Hans.Ancestor = game

function Hans.new(root: any)
    return setmetatable({
        Root = root,
    }, Hans)
end

function Hans:Start()
    self.Cleaner:Add(courier:Listen("HansAnimate"):Connect(function(newCFrame: CFrame, serverTime: number, animationLength: number)
        local difference = tonumber(string.format("%.3f", SlaveClock:GetTime() - serverTime))
        TweenService:Create(self.Root.TorsoJoint, TweenInfo.new(animationLength - difference, Enum.EasingStyle.Linear), {CFrame = newCFrame}):Play()
    end))

    self.Cleaner:Add(courier:Listen("HansUI"):Connect(function(serverTime, animationLength, attackers, defenders, currentDistance, maximumDistance)
        local difference = tonumber(string.format("%.3f", SlaveClock:GetTime() - serverTime))
    end))
end

function Hans:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Hans)

return Hans