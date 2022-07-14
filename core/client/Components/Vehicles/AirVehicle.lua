local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local CameraLimits = require(script.Parent.CameraLimits)

local Mouse = Players.LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local function getYPR(ObjectCFrame: CFrame)
	local tX, tY, tZ = ObjectCFrame:ToOrientation()
	local LV = ObjectCFrame.LookVector
	local XZDist = math.sqrt(LV.X ^ 2 + LV.Z ^ 2)
	local CFDiff = (ObjectCFrame * CFrame.Angles(0, math.rad(90), 0)):ToObjectSpace(CFrame.new(ObjectCFrame.Position, ObjectCFrame.Position + LV) * CFrame.Angles(0, math.rad(90), 0))
	
	local Yaw = math.deg(tY)
	local Pitch = math.deg(math.atan(LV.Y / XZDist))
	local Roll = -(math.deg(-math.atan2(CFDiff.LookVector.Y, CFDiff.LookVector.Z) % (math.pi * 2) + math.pi) - 360)
	return Yaw, Pitch, Roll
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> (Cleaner_T, Instance, string?)
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type AirVehicle_T = {
    __index: AirVehicle_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Engine: Part & {
            Altitude: BodyVelocity,
            Direction: BodyGyro,
        },
        PilotSeat: VehicleSeat,
    },
    Engine: Part,
    Seat: VehicleSeat,
    Altitude: BodyVelocity?,
    Direction: BodyGyro?,

    Stats: typeof(VehicleStats["Instigator"]),
    Speed: number,
    MinSpeed: number,
    MaxSpeed: number,
    IdleSpeed: number,
    DeltaSteer: number,
	TurnSpeedMax: number,
	TurnSpeedRate: number,

    SteeringVector: Vector2,

    Flying: boolean,

    SessionCleaner: typeof(Trove),

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local AirVehicle: AirVehicle_T = {}
AirVehicle.__index = AirVehicle
AirVehicle.Name = "AirVehicle"
AirVehicle.Tag = "AirVehicle"
AirVehicle.Ancestor = workspace

function AirVehicle.new(root: any)
    return setmetatable({
        Root = root,

        Flying = false,
    }, AirVehicle)
end

function AirVehicle:Start()
    local enginePart = self.Root.Engine
    assert(enginePart, "No engine for " .. self.Root.Name)
    local altitude = enginePart.Altitude
    assert(altitude, "No altitude for " .. self.Root.Name)
    local direction = enginePart.Direction
    assert(direction, "No direction for " .. self.Root.Name)
    self.Engine = enginePart
    self.Altitude = altitude
    self.Direction = direction
    
    local seat = self.Root.PilotSeat
    assert(seat, "No seat for " .. self.Root.Name)
    self.Seat = seat

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)
    self.Stats = stats
    self.Speed = stats.Speed
    self.MinSpeed = stats.MinimumSpeed or -1
    self.MaxSpeed = stats.MaximumSpeed or 1
    self.IdleSpeed = stats.IdleSpeed or 0

    self.CameraAngles = Vector2.new(0, 0)
	self.MouseDeltas = Vector2.new(0, 0)

    self.Roll = 0
	self.PitchVectors = self.Stats.PitchVectors
	self.StrafeVectors = self.Stats.StrafeVectors
	self.ReactionSpeed = self.Stats.ReactionSpeed
	self.RiseSpeed = self.Stats.RiseSpeed
    self.TakingOffOrLanding = false

    self.PreviousMousePosition = nil
end

function AirVehicle:Move(maxForce: number, p: number, velocity: Vector3)
    if maxForce then self.Altitude.MaxForce = maxForce end
    if p then self.Altitude.P = p end
    if velocity then self.Altitude.Velocity = velocity end
end

function AirVehicle:UpdateCamera()
    Camera.CameraType = Enum.CameraType.Attach
    Camera.CameraSubject = self.Engine

    -- self.CameraAngles = self.CameraAngles - (self.MouseDeltas/5)
    -- self.MouseDeltas = Vector2.new(0,0)
    -- self.CameraAngles = Vector2.new(self.CameraAngles.X, self.CameraAngles.Y)
    
    -- local angles1 = CFrame.Angles(0,math.rad(self.CameraAngles.X), 0)
    -- local angles2 = CFrame.Angles(math.rad(self.CameraAngles.Y), 0, 0)

    Camera.CFrame *= CFrame.new((VehicleStats[self.Root.Name].CameraOut or Vector3.new(0, 15, 65)))
end

function AirVehicle:RunServiceLoop()
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and self.Flying then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    local EngineC = self.Engine.CFrame
    if not self.PreviousMousePosition then
        self.PreviousMousePosition = (EngineC * CFrame.new(0, 0, -1500)).Position
    end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        self.PreviousMousePosition = (Mouse.Origin * CFrame.new(0,0,-150000)).Position
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Z) then
        self.PreviousMousePosition = Vector3.new(self.PreviousMousePosition.X,EngineC.p.Y,self.PreviousMousePosition.Z)
    end
    local targetYaw, targetPitch, targetRoll = getYPR(CFrame.new(EngineC.Position, self.PreviousMousePosition))
    local coreLook = Vector3.new(EngineC.LookVector.X, EngineC.LookVector.Y * (self.Stats.CounterGravity or .1), EngineC.LookVector.Z)
    local velocity = coreLook

    if UserInputService:IsKeyDown(Enum.KeyCode.E) and self.Flying then
        velocity += (EngineC.UpVector * self.RiseSpeed.X)
    elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) and self.Flying then
        velocity -= (EngineC.UpVector * self.RiseSpeed.Y)
    end

    if not self.TakingOffOrLanding and UserInputService:IsKeyDown(Enum.KeyCode.D) and self.Flying then
        velocity = velocity + (EngineC.RightVector * self.StrafeVectors.X)
        self.Roll = math.clamp(self.Roll - 1, -self.StrafeVectors.Y, self.StrafeVectors.Y)
    elseif not self.TakingOffOrLanding and UserInputService:IsKeyDown(Enum.KeyCode.A) and self.Flying then
       velocity = velocity - (EngineC.RightVector * self.StrafeVectors.X)
       self.Roll = math.clamp(self.Roll + 1, -self.StrafeVectors.Y, self.StrafeVectors.Y)
    else
       self.Roll = math.clamp(self.Roll - math.sign(self.Roll),-self.StrafeVectors.Y,self.StrafeVectors.Y)
    end
    
    -- if self.Flying then
    --     if (self.Roll - targetRoll) > 0 then
    --         self.Roll = targetRoll + math.clamp(self.Roll - 1, -self.StrafeVectors.Y, self.StrafeVectors.Y)
    --     elseif (self.Roll - targetRoll) < 0 then
    --         self.Roll = targetRoll + math.clamp(self.Roll + 1, -self.StrafeVectors.Y, self.StrafeVectors.Y)
    --     else
    --         self.Roll = targetRoll
    --     end
    -- end

    if not self.TakingOffOrLanding then
        velocity = velocity + (coreLook * (self.IdleSpeed * self.Stats.Speed))
    end
    
    velocity = self.Altitude.Velocity:Lerp(velocity, self.ReactionSpeed)
    if self.TakingOffOrLanding then
        velocity = Vector3.new(velocity.X / 8, velocity.Y * 1.025, velocity.Z / 8)
    else
        velocity = Vector3.new(velocity.X, velocity.Y * 1.025, velocity.Z)
    end
    
    self.Direction.CFrame =
        CFrame.new(EngineC.Position)
            *CFrame.Angles(0, math.rad(targetYaw), 0)
            *CFrame.Angles(math.rad(math.clamp(targetPitch, self.PitchVectors.X, self.PitchVectors.Y)), 0, 0)
            *CFrame.Angles(0, 0, math.rad(self.Roll))
    
    self:UpdateCamera()
    
    if self.Flying then
        self:Move(Vector3.new(500000, 1500000, 500000), 500, velocity)
    else
        self:Move(Vector3.new(0, 0, 0), nil, velocity)
    end
end

local function inputProcessor(self: AirVehicle_T, input: InputObject, processed: boolean)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Y then
        self.Flying = not self.Flying
    end
end

function AirVehicle:Bind()
    local sessionCleaner = Trove.new()
    self.Cleaner:Add(sessionCleaner, "Clean")
    self.SessionCleaner = sessionCleaner

    if self.Flying then
        self:Move(Vector3.new(500, 500, 500), 500, Vector3.new(0, 0, 0))
    else
        self:Move(Vector3.new(0, 0, 0), 0, Vector3.new(0, 0, 0))
    end

    sessionCleaner:Add(UserInputService.InputBegan:Connect(function(input, processed) inputProcessor(self, input, processed) end))
    sessionCleaner:Add(UserInputService.InputChanged:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.MouseDeltas = Vector2.new(input.Delta.X, input.Delta.Y)
        end
    end))

    sessionCleaner:Add(RunService.RenderStepped:Connect(function()
        self:RunServiceLoop()
    end))
end

function AirVehicle:Unbind()
    self.SessionCleaner:Clean()
    self.SessionCleaner = nil

    Camera.CameraType = Enum.CameraType.Custom
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    if self.Flying then
        self:Move(Vector3.new(500, 500, 500), 500, Vector3.new(0, 0, 0))
    else
        self:Move(Vector3.new(0, 0, 0), 0, Vector3.new(0, 0, 0))
    end

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)
    self.Stats = stats
    self.Speed = stats.Speed
    self.MinSpeed = stats.MinimumSpeed or -1
    self.MaxSpeed = stats.MaximumSpeed or 1
    self.IdleSpeed = stats.IdleSpeed or 0

    self.Roll = 0
	self.PitchVectors = self.Stats.PitchVectors
	self.StrafeVectors = self.Stats.self.StrafeVectors
	self.ReactionSpeed = self.Stats.ReactionSpeed
	self.RiseSpeed = self.Stats.self.RiseSpeed
    self.TakingOffOrLanding = false

    self.PreviousMousePosition = nil
end

function AirVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(AirVehicle)

return AirVehicle
