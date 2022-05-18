local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EffectRemote = ReplicatedStorage:WaitForChild("EffectRemote")
local LocalPlayer = Players.LocalPlayer

return function(self, bool, character, skillModel)
	local multiplier = 50000
	
	if bool then
		self:DepleteEnergy(self.Stats.EnergyDeplete) -- replace this line with hardcoded d0dg-p energy depletion stats
		LocalPlayer:SetAttribute("LocalSprinting", false)
		LocalPlayer:SetAttribute("LocalCrouching", false)
		
		skillModel.Propeller1.Flame.Enabled = true
        skillModel.Propeller2.Flame.Enabled = true
        skillModel.Propeller1.Material = Enum.Material.Neon
        skillModel.Propeller2.Material = Enum.Material.Neon
		
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		linearVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		linearVelocity.VectorVelocity = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		linearVelocity.Parent = character.HumanoidRootPart

		task.delay(0.8, function()
			skillModel.Propeller1.Flame.Enabled = false
			skillModel.Propeller2.Flame.Enabled = false
			skillModel.Propeller1.Material = Enum.Material.SmoothPlastic
			skillModel.Propeller2.Material = Enum.Material.SmoothPlastic

			linearVelocity:Destroy()
		end)

		self:RegenEnergy()
	end
end