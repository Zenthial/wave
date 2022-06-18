local module = {
	-- Note: CFrame.Angles is throwing arbitrary errors if one attempts to use math.rad() inside of it
	-- Hence all these obscene numbers
	Back = {
		{
			limb = "Torso",
			C0 = CFrame.new(0.25,0.5,0.6), 
			C1 = CFrame.Angles(math.rad(30), math.rad(90), math.rad(270))
		},
		{
			limb = "Torso",
			C0 = CFrame.new(0.25,0.5,0.6), 
			C1 = CFrame.Angles(math.rad(30), math.rad(90), math.rad(270)) --CFrame.Angles(math.rad(30), math.rad(90), math.rad(270))
		}
	},
	Hip = { 	
		{
			limb = "Torso",
			C0 = CFrame.new(1.15,-.65,0),
			C1 = CFrame.Angles(math.rad(110),0,0)
		},
		{
			limb = "Torso",
			C0 = CFrame.new(-1.15,-.65,0),
			C1 = CFrame.Angles(math.rad(110), 0, 0)--CFrame.Angles(math.rad(110),0,0)
		}
	},
	TorsoModule = {
		{
			limb = "Torso",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180))
		}
	},
	RightArmModule = {
		{
			limb = "Right Arm",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180))--CFrame.Angles(math.rad(180), 0, math.rad(180))
		}
	},
	LeftArmModule = {
		{
			limb = "Left Arm",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(math.rad(180), 0, math.rad(180))--CFrame.Angles(math.rad(180), 0, math.rad(180))
		}
	},
	Melee = {
		limb = "Torso",
		C0 = CFrame.new(-1.15,-.65,0),
		C1 = CFrame.Angles(math.rad(110),0,0)--CFrame.Angles(math.rad(110),0,0)
	},
	Datacore = {
		{
			limb = "Torso",
			C0 = CFrame.new(0, 0, 0.6),
			C1 = CFrame.Angles(math.rad(90), math.rad(180), math.rad(90))
		},
	}
}

return module
