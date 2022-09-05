local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Player = Players.LocalPlayer
local PlayerFolder = ReplicatedStorage:WaitForChild("PlayerFolders"):WaitForChild(Players.LocalPlayer.Name):WaitForChild("SkillRemoteFolder")
local SH3L_SRemote = PlayerFolder:WaitForChild(Players.LocalPlayer.Name.."_SH3L_SRemote") :: RemoteEvent

local REGEN_RATE = 0.3
local active = false

return function(skillStats, bool, regenEnergy, depleteEnergy)
    if not active then
        if Player:GetAttribute("Health") >= Player:GetAttribute("MaxHealth") then return end
        active = true
        
        task.spawn(function()
            Player:GetAttributeChangedSignal("Health"):Connect(function()
                if Player:GetAttribute("Health") >= Player:GetAttribute("MaxHealth") then active = false end
            end)

            while active do
                SH3L_SRemote:FireServer()
                task.wait(REGEN_RATE)
            end
        end)
    elseif active or bool == false then
        active = false
    end
end