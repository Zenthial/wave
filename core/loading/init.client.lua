local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local IntroUI = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("UI"):WaitForChild("IntroUI"):Clone()

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

IntroUI.Parent = PlayerGui

StarterGui:RemoveDefaultLoadingScreen()
