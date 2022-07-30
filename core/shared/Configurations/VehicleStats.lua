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
		Speed = 75,
		PitchVectors = Vector2.new(-25,10), --Forward, Backward
		StrafeVectors = Vector2.new(50,10), --Speed limit, roll angle limit
		ReactionSpeed = 0.1, --Lerp fraction between previous and current target velocity
		RiseSpeed = Vector2.new(15,25), --Up, Down
		--BodyGyro
		DirectionD = 150,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
	},
	["Sweeper"] = {
		Speed = 600,
		PitchVectors = Vector2.new(-20, 20), --Forward, Backward
		StrafeVectors = Vector2.new(25, 35), --Speed limit, roll angle limit
		ReactionSpeed = 0.1, --Lerp fraction between previous and current target velocity
		RiseSpeed = Vector2.new(15,20), --Up, Down
		--BodyGyro
		DirectionD = 400,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		--
		CameraType = "Attach", --Defaults to Scriptable
		
		--Throttle, -1 to 1, like on vehicleseats, can go over/under but why? Increase/decrease speed instead.
		MinimumSpeed = 0.2, --S
		IdleSpeed = 0.6, --(Neither W or S) or (W and S)
		MaximumSpeed = 1, --W
		
		--Camera limits
		CameraMinY = -40,
		CameraMaxY = 10,
		CameraMinX = -5,
		CameraMaxX = 5,
		
		CounterGravity = 1, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Dropship"] = {
		Speed = 60,
		PitchVectors = Vector2.new(-25,10), --Forward, Backward
		StrafeVectors = Vector2.new(20,5), --Speed limit, roll angle limit
		ReactionSpeed = 0.1, --Lerp fraction between previous and current target velocity
		RiseSpeed = Vector2.new(15,25), --Up, Down
		--BodyGyro
		DirectionD = 150,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		MinimumSpeed = 0.4, --S
	},
	["Striker"] = {
		Speed = 150,
		PitchVectors = Vector2.new(-30,30), --Forward, Backward
		StrafeVectors = Vector2.new(40,25), --Speed limit, roll angle limit
		ReactionSpeed = 0.1, --Lerp fraction between previous and current target velocity
		RiseSpeed = Vector2.new(10,15), --Up, Down
		--BodyGyro
		DirectionD = 150,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		--
		
		--Throttle, -1 to 1, like on vehicleseats, can go over/under but why? Increase/decrease speed instead.
		MinimumSpeed = 0.2, --S
		IdleSpeed = 0.4, --(Neither W or S) or (W and S)
		MaximumSpeed = 1, --W
		
		CounterGravity = .3, --Multiplier of lookVector.Y for BodyVelocity
	},
	["Gunship"] = {
		Speed = 70,
		PitchVectors = Vector2.new(-35,20), --Forward, Backward
		StrafeVectors = Vector2.new(3,35), --Speed limit, roll angle limit
		ReactionSpeed = 0.1, --Lerp fraction between previous and current target velocity
		RiseSpeed = Vector2.new(10,20), --Up, Down
		--BodyGyro
		DirectionD = 250,
		DirectionTorque = Vector3.new(300000, 300000, 300000),
		DirectionP = 500,
		MinimumSpeed = 0.4, --S
		
		CounterGravity = .05,
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
	}
}

return Vehicles
