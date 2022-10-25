local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local SkillRemoteFolder = ReplicatedStorage:WaitForChild("PlayerFolders"):WaitForChild(LocalPlayer.Name):WaitForChild("SkillRemoteFolder")
local InvisRemote = SkillRemoteFolder:WaitForChild(LocalPlayer.Name.."_InvisRemote") :: RemoteEvent

local TRANSPARENCY = 0.98
local ENERGY_WAIT_TIME = 0.2

local archivedParts = nil

type SkillStats = {
    SkillName: string,
    SkillModel: Model,

    Energy: number,
    Recharging: boolean,
    Active: boolean
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
    print("here")
    if not skillStats.Active then
        skillStats.Active = true

        local partsTable = archivedParts

        if partsTable == nil then
            local foldersTable = {character:GetDescendants(), skillStats.SkillModel:GetDescendants()}
            local parts = {}

            for _, v in pairs(foldersTable) do
                for _, k in pairs(v) do
                    if (k:IsA("BasePart") or k:IsA("Decal")) and k.Transparency < 1 then
                        table.insert(parts, k)
                    end
                end
            end
    
            archivedParts = parts
            partsTable = parts
        end

        print("here :", partsTable)
        InvisRemote:FireServer(partsTable, TRANSPARENCY)

        task.spawn(function()
            while skillStats.Active do
                depleteEnergy(skillStats, skillStats.WeaponStats.EnergyDeplete)
                task.wait(ENERGY_WAIT_TIME)
            end

            skillStats.Active = false
        end)
    elseif skillStats.Active or bool == false then
        skillStats.Active = false

        local partsTable = archivedParts

        if partsTable == nil then
            local foldersTable = {character:GetDescendants(), skillStats.SkillModel:GetDescendants()}
            local parts = {}

            for _, v in pairs(foldersTable) do
                for _, k in v do
                    if (k:IsA("BasePart") or k:IsA("Decal")) and k.Transparency < 1 then
                        table.insert(parts, k)
                    end
                end
            end
    
            archivedParts = parts
            partsTable = parts
        end

        InvisRemote:FireServer(partsTable)

        regenEnergy(skillStats)
    end
end