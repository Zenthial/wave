local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local LocalPlayer = Players.LocalPlayer

type SkillStats = {
    SkillName: string,
    SkillModel: Model,

    Energy: number,
    Recharging: boolean,
    Active: boolean
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
    if bool then
        skillStats.Active = true
        depleteEnergy(skillStats, skillStats.EnergyDeplete)
        LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)

        Courier:Send("EffectEnable", skillStats.SkillModel.Reactor.FieldExplosion, true)
        Courier:Send("AoERadius", skillStats.SkillModel.Reactor, "HEAL-X")
        skillStats.SkillModel.Reactor.FieldExplosionSound:Play()

        LocalPlayer:SetAttribute("FielxActive", true)
		
		task.wait(0.5)
		
        LocalPlayer:SetAttribute("FielxActive", false)
        Courier:Send("EffectEnable", skillStats.SkillModel.Reactor.FieldExplosion, false)
		
        skillStats.Active = false
		regenEnergy(skillStats)
    end
end