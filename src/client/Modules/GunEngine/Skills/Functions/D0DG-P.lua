return function(bool, character, movementComponent, skillModel)
	local multiplier = 3250
	
	if bool then
		movementComponent:SetSprint(false)
		movementComponent:SetCrouch(false)
		
		skillModel.Propeller1.Flame.Enabled = true
        skillModel.Propeller2.Flame.Enabled = true
        skillModel.Propeller1.Material = Enum.Material.Neon
        skillModel.Propeller2.Material = Enum.Material.Neon
		
		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		local linearVelocity = Instance.new("LinearVelocity")
		linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
		linearVelocity.MaxForce = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		linearVelocity.VectorVelocity = Vector3.new(character.Humanoid.MoveDirection.X * multiplier, 1000, character.Humanoid.MoveDirection.Z * multiplier)
		linearVelocity.Parent = character.Torso or character.LowerTorso
		
		task.wait(0.8)
		
		skillModel.Propeller1.Flame.Enabled = false
        skillModel.Propeller2.Flame.Enabled = false
        skillModel.Propeller1.Material = Enum.Material.SmoothPlastic
        skillModel.Propeller2.Material = Enum.Material.SmoothPlastic

		linearVelocity:Destroy()
	end
end