-- Need to migrate functionality from SkillHandler component to here
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local SkillService = {}

function SkillService:Start()
    courier:Listen("PoisonDamage"):Connect(function(sourcePlayer: Player, playersNear: {Player})
        if sourcePlayer:GetAttribute("EquippedSkill") ~= "POIS-N" then return end
        local poisonStats = WeaponStats["POIS-N"]
        local totalDamage = 0
        for _, player in playersNear do
            local healthComponent = tcs.get_component(player, "Health")

            if player.TeamColor ~= sourcePlayer.TeamColor then
                healthComponent:TakeDamage(poisonStats.Damage)
                totalDamage += poisonStats.Damage
            end
        end

        local sourceHealthComponent = tcs.get_component(sourcePlayer, "Health")
        sourceHealthComponent:Heal(totalDamage * poisonStats.HealFactor)
    end)
end

return SkillService