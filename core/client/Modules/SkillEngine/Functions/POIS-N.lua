local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local radiusRaycast = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("radiusRaycast"))

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local poisonActive = false
local previousBeamPlayers = {}

local POISON_RATE = 0.3

type SkillStats = {
    SkillName: string,
    SkillModel: Model,

    Energy: number,
    Recharging: boolean,
	Active: boolean,
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
    if bool then
        poisonActive = true

        task.spawn(function()
            for _, particle in skillStats.SkillModel["Lime green"].Sphere:GetChildren() do
                Courier:Send("EffectEnable", particle, true)
            end

            while poisonActive do
                local playersNear = radiusRaycast(character.HumanoidRootPart.Position, 10)
                Courier:Send("PoisonDamage", playersNear)

                local currentTime = os.time()
                for _, player in pairs(playersNear) do
                    if player.TeamColor == LocalPlayer.TeamColor then continue end
                    if previousBeamPlayers[player] == nil then
                        Courier:Send("MakeBeam", player)
                    end
                    previousBeamPlayers[player] = currentTime
                end

                for player, time in pairs(previousBeamPlayers) do
                    if time ~= currentTime then
                        Courier:Send("RemoveBeam", player)
                        previousBeamPlayers[player] = nil
                    end
                end

                depleteEnergy(skillStats, skillStats.WeaponStats.EnergyDeplete)
                task.wait(POISON_RATE)
            end
        end)
    else
        poisonActive = false

        for _, particle in skillStats.SkillModel["Lime green"].Sphere:GetChildren() do
            Courier:Send("EffectEnable", particle, false)
        end

        for player, _ in pairs(previousBeamPlayers) do
            Courier:Send("RemoveBeam", player)
        end

        previousBeamPlayers = {}

        regenEnergy(skillStats)
    end
end