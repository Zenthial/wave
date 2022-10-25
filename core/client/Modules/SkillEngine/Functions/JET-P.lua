local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

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
		depleteEnergy(skillStats, skillStats.WeaponStats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		Courier:Send("EffectEnable", skillStats.SkillModel.Propeller.Flame, true)
		

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * 1200, 25 * skillStats.Energy, character.Humanoid.MoveDirection.Z * 1200)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(character.Humanoid.MoveDirection.X * 1200, 25 * skillStats.Energy, character.Humanoid.MoveDirection.Z * 1200)
	
		task.spawn(function()
			
		end)
	else
		skillStats.Active = false
		Courier:Send("EffectEnable", skillStats.SkillModel.Propeller.Flame, false)

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(0, 0, 0)

		regenEnergy(skillStats)
	end
end