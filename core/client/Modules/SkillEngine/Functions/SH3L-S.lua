local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Player = Players.LocalPlayer
local PlayerFolder = ReplicatedStorage:WaitForChild("PlayerFolders"):WaitForChild(Players.LocalPlayer.Name):WaitForChild("SkillRemoteFolder")
local SH3L_SRemote = PlayerFolder:WaitForChild(Players.LocalPlayer.Name.."_SH3L_SRemote") :: RemoteEvent

local REGEN_RATE = 0.3

type SkillStats = {
    SkillName: string,
    SkillModel: Model,

    Energy: number,
    Recharging: boolean,
	Active: boolean,
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
    if not skillStats.Active then
        if Player:GetAttribute("Health") >= Player:GetAttribute("MaxHealth") then return end
        skillStats.Active = true
        
        task.spawn(function()
            Player:GetAttributeChangedSignal("Health"):Connect(function()
                if Player:GetAttribute("Health") >= Player:GetAttribute("MaxHealth") then skillStats.Active = false end
            end)

            while skillStats.Active do
                SH3L_SRemote:FireServer()
                task.wait(REGEN_RATE)
            end
        end)
    elseif skillStats.Active or bool == false then
        skillStats.Active = false
    end
end