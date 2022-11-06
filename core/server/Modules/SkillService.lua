-- Need to migrate functionality from SkillHandler component to here
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local SkillService = {}

function SkillService:Start()
    courier:Listen("SiphonDamage"):Connect(function(sourcePlayer: Player, playersNear: {Player})
        if sourcePlayer:GetAttribute("EquippedSkill") ~= "SIPH-N" then return end
        local siphonStats = WeaponStats["SIPH-N"]
        local totalDamage = 0
        for _, player in playersNear do
            local healthComponent = tcs.get_component(player, "Health")

            if player.TeamColor ~= sourcePlayer.TeamColor then
                healthComponent:TakeDamage(siphonStats.Damage)
                totalDamage += siphonStats.Damage
            end
        end

        local sourceHealthComponent = tcs.get_component(sourcePlayer, "Health")
        sourceHealthComponent:Heal(totalDamage * siphonStats.HealFactor)
    end)
end

return SkillService