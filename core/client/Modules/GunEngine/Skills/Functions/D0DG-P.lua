local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectEnableRemote = ReplicatedStorage:WaitForChild("EffectEnableRemote")
local MaterialChangeRemote = ReplicatedStorage:WaitForChild("MaterialChangeRemote")
local LocalPlayer = Players.LocalPlayer

return function(self, bool, character, skillModel)
	local multiplier = 3250
	
	if bool then
		self:DepleteEnergy(self.Stats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		EffectEnableRemote:FireServer(skillModel.Propeller1.Flame, true)
        EffectEnableRemote:FireServer(skillModel.Propeller2.Flame, true)
        MaterialChangeRemote:FireServer(skillModel.Propeller1.Material, Enum.Material.Neon)
        MaterialChangeRemote:FireServer(skillModel.Propeller2.Material, Enum.Material.Neon)
		
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)

		task.delay(0.8, function()
			EffectEnableRemote:FireServer(skillModel.Propeller1.Flame, false)
			EffectEnableRemote:FireServer(skillModel.Propeller2.Flame, false)
			MaterialChangeRemote:FireServer(skillModel.Propeller1.Material, Enum.Material.SmoothPlastic)
			MaterialChangeRemote:FireServer(skillModel.Propeller2.Material, Enum.Material.SmoothPlastic)

			shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
			shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end)

		self:RegenEnergy()
	end
end