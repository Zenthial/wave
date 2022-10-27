--[[

-- Local list of terminology --

*Assumed that aircraft's primary axis is Roll, which will be called X -blockhead
Pitch - An aircraft's Z-axis, so to speak
Yaw   - An aircraft's Y-axis, so to speak
Roll  - An aircraft's X-axis, so to speak
]]--
-------------------------------------------------------------------------------------------
local Vehicles = {
	["Turret"] = { --Generic turret, just set here for the camera.
		CameraType = "Orbit",
		Speed = 0,
		TurnSpeedMax = 0,
		TurnSpeedRate = 0,
	},
------------------------------------------------------------------------------------
	["Maelstrom"] = {
		TurnSpeedMax = 1, --Steering, max speed
		TurnSpeedRate = 0.25, --Steering direction change speed
		Speed = 25,
		AccelerateSpeed = 25, --These two are for motors
		DecelerateSpeed = 100,--This is the other one for motors
        
        DefaultHealth = 1000,
        RegenRate = 0,
        RegenSpeed = 0
	},
	["Pobber"] = {
		TurnSpeedMax = 2, --Steering, max speed
		TurnSpeedRate = 0.25, --Steering direction change speed
		Speed = 80,
		AccelerateSpeed = 25, --These two are for motors
		DecelerateSpeed = 100,--This is the other one for motors
		CameraType = "Orbit",

        DefaultHealth = 500,
        RegenRate = 10,
        RegenSpeed = 2
	},
	["Equalizer"] = {
		TurnSpeedMax = 1, --Steering, max speed
		TurnSpeedRate = 0.25, --Steering direction change speed
		Speed = 25,
		AccelerateSpeed = 25, --These two are for motors
		DecelerateSpeed = 100,--This is the other one for motors
		CameraType = "Orbit",

        DefaultHealth = 1500,
        RegenRate = 0,
        RegenSpeed = 0
	},
	["Thunder"] = {
		TurnSpeedMax = 1, --Steering, max speed
		TurnSpeedRate = 0.25, --Steering direction change speed
		Speed = 25,
		AccelerateSpeed = 25, --These two are for motors
		DecelerateSpeed = 100,--This is the other one for motors
		CameraType = "Orbit",

        DefaultHealth = 2000,
        RegenRate = 0,
        RegenSpeed = 0
	},
	["Instigator"] = {
		TurnSpeedMax = 1, --Steering, max speed
		TurnSpeedRate = 0.25, --Steering direction change speed
		Speed = 70,
		AccelerateSpeed = 25, --These two are for motors
		DecelerateSpeed = 100,--This is the other one for motors
		CameraType = "Orbit",

        DefaultHealth = 1000,
        RegenRate = 0,
        RegenSpeed = 0
	},
------------------------------------------------------------------------------------
	["Shuttle"] = {
		Health = 800,
		PitchVectors = Vector2.new(-25,10), --Forward, Backward
		StrafeVectors = Vector2.new(50,12), --Speed limit, roll angle limit
		--BodyGyro
		DirectionD = 300,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		CameraOut = Vector3.new(0, 15, 50),

		MinimumSpeed = 100, --S
		MaximumSpeed = 200, --W
		SpeedIncreaseRate = 0.5, -- How fast the speed increases (per frame)
		MaxForce = 5000000,

		CounterGravity = 1
	},
	["Sweeper"] = {
		Health = 750, -- Max health
		PitchVectors = Vector2.new(-20, 20), --Forward, Backward
		StrafeVectors = Vector2.new(25, 35), --Speed limit, roll angle limit
		--BodyGyro
		DirectionD = 400,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		
		--Throttle, -1 to 1, like on vehicleseats, can go over/under but why? Increase/decrease speed instead.
		MinimumSpeed = 90, --S
		MaximumSpeed = 200, --W
		SpeedIncreaseRate = 0.2, -- How fast the speed increases (per frame)
		MaxForce = 5000000,
		
		--Camera limits
		CameraMinY = -40,
		CameraMaxY = 10,
		CameraMinX = -5,
		CameraMaxX = 5,
		
		CounterGravity = 1.025, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Swan"] = {
		Health = 750,
		PitchVectors = Vector2.new(-25,10), --Forward, Backward
		StrafeVectors = Vector2.new(20,5), --Speed limit, roll angle limit
		--BodyGyro
		DirectionD = 150,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,

		MinimumSpeed = 20, --S
		MaximumSpeed = 300, --W
		SpeedIncreaseRate = 5, -- How fast the speed increases (per frame)
		MaxForce = 5000000,

		CounterGravity = 1.025, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Whale"] = {
		Health = 2000, -- Max health
		PitchVectors = Vector2.new(-20, 20), --Forward, Backward
		StrafeVectors = Vector2.new(25, 15), --Speed limit, roll angle limit
		MaxForce = 9000000000,

		--BodyGyro
		DirectionD = 800,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		
		--Throttle, -1 to 1, like on vehicleseats, can go over/under but why? Increase/decrease speed instead.
		MinimumSpeed = 50, --S
		MaximumSpeed = 150, --W
		SpeedIncreaseRate = 0.1, -- How fast the speed increases (per frame)
		
		--Camera limits
		CameraMinY = -40,
		CameraMaxY = 10,
		CameraMinX = -5,
		CameraMaxX = 5,
		CameraOut = Vector3.new(0, 15, 95),
		
		CounterGravity = 0.95, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Striker"] = {
		Health = 500, -- Max health
		PitchVectors = Vector2.new(-30,30), --Forward, Backward
		StrafeVectors = Vector2.new(40,25), --Speed limit, roll angle limit
		MaxForce = 5000000,

		--BodyGyro
		DirectionD = 150,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		--
		
		--Throttle, -1 to 1, like on vehicleseats, can go over/under but why? Increase/decrease speed instead.
		MinimumSpeed = 200, --S
		MaximumSpeed = 600, --W
		SpeedIncreaseRate = 0.5, -- How fast the speed increases (per frame)
		
		CounterGravity = 1.025, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Albatross"] = {
		Health = 1200,
		PitchVectors = Vector2.new(-35,20), --Forward, Backward
		StrafeVectors = Vector2.new(3,35), --Speed limit, roll angle limit
		--BodyGyro
		DirectionD = 250,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		MaxForce = 5000000,

		MinimumSpeed = 10, --S
		MaximumSpeed = 200, --W
		SpeedIncreaseRate = 1, -- How fast the speed increases (per frame)
		
		CounterGravity = 0.85,
	},
	------------------------------------------------------------------------------------
	["Crusader"] = {
		Speed = 0,
		MaxTorque = Vector3.new(400000, 0, 400000),
		GyroD = 5,
		GyroP = 100,
		PositionD = 1250,
		MaxForce = Vector3.new(0,math.huge,0),
		PositionP = 100000,
		Position = 10.34
	},
	-- Boats
	["Sailfish"] = {
		TurnSpeedMax = 1, --Steering, max speed
		TurnSpeedRate = 1, --Steering direction change speed
		Speed = 80,
		AccelerateSpeed = 10, --These two are for motors
		DecelerateSpeed = 10,--This is the other one for motors
        
        DefaultHealth = 1000,
        RegenRate = 0,
        RegenSpeed = 0
	},
}

return Vehicles
