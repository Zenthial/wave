local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
ReplicatedFirst:RemoveDefaultLoadingScreen()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local LOOK_AT = CFrame.new(672.990356, 226.363541, -476.777161, 0, 0, -1, 0, 1, 0, 1, 0, 0)
local START = CFrame.new(661.277588, 228.402252, -490.431335, -0.667153001, 0.0983098745, -0.738405168, -0, 0.991253376, 0.131973594, 0.74492079, 0.0880465806, -0.661317587)

local Player = Players.LocalPlayer

Player.CharacterAdded:Wait()
task.wait(1)

local Camera = workspace.CurrentCamera
Camera.CameraType = Enum.CameraType.Scriptable
Camera.CFrame = CFrame.new(START.Position, LOOK_AT.Position)

local player = game.Players.LocalPlayer
player:SetAttribute("ReplicatedFirstClient", true)