local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local SkillRemoteFolder = ReplicatedStorage:WaitForChild("PlayerFolders"):WaitForChild(LocalPlayer.Name):WaitForChild("SkillRemoteFolder")
local InvisRemote = SkillRemoteFolder:WaitForChild(LocalPlayer.Name.."_InvisRemote") :: RemoteEvent

local TRANSPARENCY = 0.98
local ENERGY_WAIT_TIME = 0.2

local active = false
local archivedParts = nil

return function(skillStats, bool, regenEnergy, depleteEnergy)
    print("here")
    if not active then
        active = true

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
            while active do
                depleteEnergy(skillStats, skillStats.EnergyDeplete)
                task.wait(ENERGY_WAIT_TIME)
            end
        end)
    elseif active or bool == false then
        active = false

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