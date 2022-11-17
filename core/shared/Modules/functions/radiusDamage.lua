local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

if RunService:IsClient() then

    return function(stats, origin: Vector3, sourceTeam: BrickColor, canTK: boolean, sourcePlayer: Player)
        local radius = stats.NadeRadius

        local player = Players.LocalPlayer
        local character = player.Character
        local hrp = character.HumanoidRootPart

        local dist = (origin - hrp.Position).Magnitude
        local ignore = CollectionService:GetTagged("Ignore")
            
        local NewRay = Ray.new(origin + Vector3.new(0, 3, 0), (hrp.CFrame.Position - (origin + Vector3.new(0, 3, 0))).Unit * radius)
        local hit, position = workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)
        if hit and hit:IsDescendantOf(character) then
            if not canTK then
                if player.TeamColor == sourceTeam then return end
            end

            Courier:Send("DealSelfDamage", stats.CalculateDamage(stats.MaxDamage, dist), sourcePlayer, stats.Name)
        end
    end
elseif RunService:IsServer() then
    return function(stats, origin: Vector3, sourcePlayer: Player, canTK: boolean)
        local radius

        if stats.NadeRadius and stats.NadeRadius > 0 then 
            radius = stats.NadeRadius
        elseif stats.BlastRadius and stats.BlastRadius > 0 then
            radius = stats.BlastRadius
        end

        local playersNear = {}
        local maxDamage = stats.MaxDamage or stats.Damage
        for _, player: Player in pairs(Players:GetPlayers()) do
            local character = player.Character
            local hrp = character.HumanoidRootPart

            local dist = (origin - hrp.Position).Magnitude
            local ignore = CollectionService:GetTagged("Ignore")
                
            local NewRay = Ray.new(origin + Vector3.new(0, 3, 0), (hrp.CFrame.Position - (origin + Vector3.new(0, 3, 0))).Unit * radius)
            local hit, _ = workspace:FindPartOnRayWithIgnoreList(NewRay, ignore)

            if hit and hit:IsDescendantOf(character) then
                if stats.Action == "Heal" then
                    if player.TeamColor == sourcePlayer.TeamColor and player ~= sourcePlayer then
                        playersNear[player] = stats.CalculateDamage(maxDamage, dist)
                    end
                else
                    if not canTK then
                        if player.TeamColor == sourcePlayer.TeamColor then continue end
                    end
                    playersNear[player] = stats.CalculateDamage(maxDamage, dist)
                end
            end
        end

        return playersNear
    end
end