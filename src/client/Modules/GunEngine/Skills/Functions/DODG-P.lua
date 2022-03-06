return function(bool, humanoid, movementComponent, shieldModel, skillModel)
	local multiplier = 3250
	
	if bool then
		movementComponent:SetSprint(false)
		movementComponent:SetCrouch(false)
		
		skillModel.Propeller1.Flame.Enable = true
        skillModel.Propeller2.Flame.Enable = true
        skillModel.Propeller1.Material = Enum.Material.Neon
        skillModel.Propeller2.Material = Enum.Material.Neon
		
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(_G.hum.MoveDirection.X * multiplier, 1000, _G.hum.MoveDirection.Z * multiplier)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(_G.hum.MoveDirection.X * multiplier, 1000, _G.hum.MoveDirection.Z * multiplier)
		
		task.wait(0.8)
		
		skillModel.Propeller1.Flame.Enable = false
        skillModel.Propeller2.Flame.Enable = false
        skillModel.Propeller1.Material = Enum.Material.SmoothPlastic
        skillModel.Propeller2.Material = Enum.Material.SmoothPlastic
		
		shieldModel.TorsoShield.BodyVelocity.MaxForce = Vector3.new(0, 0, 0)
		shieldModel.TorsoShield.BodyVelocity.Velocity = Vector3.new(0, 0, 0)
	end
end