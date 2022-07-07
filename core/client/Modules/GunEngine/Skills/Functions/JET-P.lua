local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectEnableRemote = ReplicatedStorage:WaitForChild("EffectEnableRemote")
local MaterialChangeRemote = ReplicatedStorage:WaitForChild("MaterialChangeRemote")
local LocalPlayer = Players.LocalPlayer

return function(self, bool, character, skillModel)	
	if bool then
		self:DepleteEnergy(self.Stats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		EffectEnableRemote:FireServer(skillModel.Propeller.Flame, true)
		

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * 1200, 25 * self.CurrentEnergy, character.Humanoid.MoveDirection.Z * 1200)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(character.Humanoid.MoveDirection.X * 1200, 25 * self.CurrentEnergy, character.Humanoid.MoveDirection.Z * 1200)
	
		task.spawn(function()
			
		end)
	else
		EffectEnableRemote:FireServer(skillModel.Propeller.Flame, false)

		local shieldModel = character.ShieldModel
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(0, 0, 0)

		self:RegenEnergy()
	end
end