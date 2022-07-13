local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local IntroUI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("IntroUI"):Clone()

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

IntroUI.Parent = PlayerGui

ReplicatedFirst:RemoveDefaultLoadingScreen()

task.wait(3)

IntroUI:Destroy()
-- This is temporary until we decide what we want