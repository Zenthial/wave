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
	Active: boolean,
}

return function(skillStats: SkillStats, bool, regenEnergy, depleteEnergy)
	local multiplier = 3250
	
	if bool then
		skillStats.Active = true
		depleteEnergy(skillStats, skillStats.WeaponStats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		Courier:Send("EffectEnable", skillStats.SkillModel.Propeller1.Flame, true)
        Courier:Send("EffectEnable", skillStats.SkillModel.Propeller2.Flame, true)
        Courier:Send("MaterialChange", skillStats.SkillModel.Propeller1, Enum.Material.Neon)
        Courier:Send("MaterialChange", skillStats.SkillModel.Propeller2, Enum.Material.Neon)
		
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)

		task.delay(0.8, function()
			Courier:Send("EffectEnable", skillStats.SkillModel.Propeller1.Flame, false)
			Courier:Send("EffectEnable", skillStats.SkillModel.Propeller2.Flame, false)
			Courier:Send("MaterialChange", skillStats.SkillModel.Propeller1, Enum.Material.SmoothPlastic)
			Courier:Send("MaterialChange", skillStats.SkillModel.Propeller2, Enum.Material.SmoothPlastic)

			shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
			shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end)

		skillStats.Active = false
		regenEnergy(skillStats)
	end
end