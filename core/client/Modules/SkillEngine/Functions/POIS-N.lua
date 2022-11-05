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

                local beamPlayers = table.clone(previousBeamPlayers)
                for _, player in pairs(playersNear) do
                    if beamPlayers[player] == nil then
                        Courier:Send("MakeBeam", player)
                        beamPlayers[player] = true
                    else
                        previousBeamPlayers[player] = nil                        
                    end
                end

                if #previousBeamPlayers > 0 then
                    for player, _ in pairs(previousBeamPlayers) do
                        Courier:Send("RemoveBeam", player)
                    end
                end

                previousBeamPlayers = beamPlayers

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