local module = {
	-- Note: CFrame.Angles is throwing arbitrary errors if one attempts to use math.rad() inside of it
	-- Hence all these obscene numbers
	Back = {
		{
			limb = "Torso",
			C0 = CFrame.new(0.25,0.5,0.6), 
			C1 = CFrame.Angles(0.5235987755983, 1.5707963267949,4.7123889803847)
		},
		{
			limb = "Torso",
			C0 = CFrame.new(0.25,0.5,0.6), 
			C1 = CFrame.Angles(0.5235987755983, 1.5707963267949,4.7123889803847) --CFrame.Angles(math.rad(30), math.rad(90), math.rad(270))
		}
	},
	Hip = { 	
		{
			limb = "Torso",
			C0 = CFrame.new(1.15,-.65,0),
			C1 = CFrame.Angles(1.9198621771938, 0, 0)
		},
		{
			limb = "Torso",
			C0 = CFrame.new(-1.15,-.65,0),
			C1 = CFrame.Angles(1.9198621771938, 0, 0)--CFrame.Angles(math.rad(110),0,0)
		}
	},
	TorsoModule = {
		{
			limb = "Torso",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(3.1415926535898, 0, 3.1415926535898)
		}
	},
	RightArmModule = {
		{
			limb = "Right Arm",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(3.1415926535898, 0, 3.1415926535898)--CFrame.Angles(math.rad(180), 0, math.rad(180))
		}
	},
	LeftArmModule = {
		{
			limb = "Left Arm",
			C0 = CFrame.new(0,0,0), 
			C1 = CFrame.Angles(3.1415926535898, 0, 3.1415926535898)--CFrame.Angles(math.rad(180), 0, math.rad(180))
		}
	},
	Melee = {
		limb = "Torso",
		C0 = CFrame.new(-1.15,-.65,0),
		C1 = CFrame.Angles(1.9198621771938, 0, 0)--CFrame.Angles(math.rad(110),0,0)
	}	
}

return module
