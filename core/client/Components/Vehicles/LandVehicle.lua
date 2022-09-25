local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> (Cleaner_T, Instance, string?)
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type LandVehicle_T = {
    __index: LandVehicle_T,
    Name: string,
    Tag: string,
    Root: Model & {
        Chassis: Model & {
            VehicleSeat: VehicleSeat,
            Engine: Part & {
                BodyAngularVelocity: BodyAngularVelocity,
                BodyGyro: BodyGyro,
                BodyVelocity: BodyVelocity
            }
        },
    },
    Engine: Part,
    Seat: VehicleSeat,
    BodyAngularVelocity: BodyAngularVelocity?,
    BodyGyro: BodyGyro?,
    BodyVelocity: BodyVelocity?,

    Stats: typeof(VehicleStats["Instigator"]),
    Speed: number,
    MinSpeed: number,
    MaxSpeed: number,
    IdleSpeed: number,
    DeltaSteer: number,
	TurnSpeedMax: number,
	TurnSpeedRate: number,

    SteeringVector: Vector2,

    SessionCleaner: typeof(Trove),

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local LandVehicle: LandVehicle_T = {}
LandVehicle.__index = LandVehicle
LandVehicle.Name = "LandVehicle"
LandVehicle.Tag = "LandVehicle"
LandVehicle.Ancestor = workspace

function LandVehicle.new(root: any)
    return setmetatable({
        Root = root,
    }, LandVehicle)
end

function LandVehicle:Start()
    local enginePart = self.Root.Chassis.Engine
    assert(enginePart, "No engine for " .. self.Root.Name)
    local bodyAngularVelocity = enginePart.BodyAngularVelocity
    assert(bodyAngularVelocity, "No angular velocity for " .. self.Root.Name)
    local bodyGyro = enginePart.BodyGyro
    assert(bodyGyro, "No gyro for " .. self.Root.Name)
    local bodyVelocity = enginePart.BodyVelocity
    assert(bodyVelocity, "No velocity for " .. self.Root.Name)
    self.Engine = enginePart
    self.BodyAngularVelocity = bodyAngularVelocity
    self.BodyVelocity = bodyVelocity
    self.BodyGyro = bodyGyro

    local seat = self.Root.Chassis.VehicleSeat
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

    self.SteeringVector = Vector2.new(0, self.IdleSpeed)

    self.DeltaSteer = 0
	self.TurnSpeedMax = stats.TurnSpeedMax
	self.TurnSpeedRate = stats.TurnSpeedRate
end

function LandVehicle:IsVehicleFlipped()
    return (self.Root.Chassis.VehicleSeat.CFrame * CFrame.Angles(math.pi/2,0,0)).LookVector.Y < 0.2        
end

function LandVehicle:Move(direction: number)
    self.BodyVelocity.Velocity = self.Seat.CFrame.LookVector * direction
end

function LandVehicle:UpdateSteering()
    local velocityX, velocityY = 0, 0

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        velocityY += 1
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        velocityY -= 1
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        velocityX += 1
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        velocityX -= 1
    end

    if velocityY == 0 then velocityY = self.IdleSpeed end

    self.SteeringVector = Vector2.new(math.clamp(velocityX, -1, 1), math.clamp(velocityY, self.MinSpeed, self.MaxSpeed))
end

function LandVehicle:UpdateMovement()
    self:UpdateSteering()
    
    if self.SteeringVector.Y > 0 then
        self:Move(self.Speed * self.SteeringVector.Y)
    elseif self.SteeringVector.Y < 0 then
        self:Move((self.Speed * self.SteeringVector.Y) / 3)
    else
        self:Move(0)
    end
end

function LandVehicle:UpdateCamera()
    Camera.CameraType = Enum.CameraType.Scriptable

    self.CameraAngles = self.CameraAngles - (self.MouseDeltas/5)
    self.MouseDeltas = Vector2.new(0,0)
    self.CameraAngles = Vector2.new(self.CameraAngles.X, self.CameraAngles.Y)
    
    local angles1 = CFrame.Angles(0,math.rad(self.CameraAngles.X), 0)
    local angles2 = CFrame.Angles(math.rad(self.CameraAngles.Y), 0, 0)

    Camera.CFrame = CFrame.new(self.Engine.CFrame.Position) * CFrame.Angles(0, math.rad(90), 0) * angles1 * angles2 * CFrame.new((VehicleStats[self.Root.Name].CameraOut or Vector3.new(0, 15, 65)))
end

function LandVehicle:RunServiceLoop()
    if self.SteeringVector.X == 0 then
        if math.abs(self.DeltaSteer) <= self.TurnSpeedRate then
            self.DeltaSteer = 0
        end

        if self.DeltaSteer > 0 then
            self.DeltaSteer -= self.TurnSpeedRate
            self:UpdateMovement()
        elseif self.DeltaSteer < 0 then
            self.DeltaSteer += self.TurnSpeedRate
            self:UpdateMovement()
        end
    else
        local throttleX = self.SteeringVector.X
        local TSMxAbsThrottleX = self.TurnSpeedMax * math.abs(throttleX)
        self.DeltaSteer = math.clamp(self.DeltaSteer + (throttleX * self.TurnSpeedRate),-TSMxAbsThrottleX,TSMxAbsThrottleX)
        self:UpdateMovement()
    end

    if not self:IsVehicleFlipped() then
        self.BodyAngularVelocity.MaxTorque = Vector3.new(0, 25000000, 0)
        self.BodyAngularVelocity.AngularVelocity = Vector3.new(0, self.DeltaSteer, 0)
    end

    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end

    self:UpdateCamera()
end

local function inputProcessor(self, input: InputObject, processed: boolean)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.A then
        self:UpdateMovement()
    end
end

function LandVehicle:Bind()
    local sessionCleaner = Trove.new()
    self.Cleaner:Add(sessionCleaner, "Clean")
    self.SessionCleaner = sessionCleaner

    self:Move(0)

    sessionCleaner:Add(UserInputService.InputBegan:Connect(function(input, processed) inputProcessor(self, input, processed) end))
    sessionCleaner:Add(UserInputService.InputEnded:Connect(function(input, processed) inputProcessor(self, input, processed) end))
    sessionCleaner:Add(UserInputService.InputChanged:Connect(function(input, processed)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            self.MouseDeltas = Vector2.new(input.Delta.X, input.Delta.Y)
        end
    end))

    sessionCleaner:Add(RunService.RenderStepped:Connect(function()
        self:RunServiceLoop()
    end))
end

function LandVehicle:Unbind()
    self.SessionCleaner:Clean()
    self.SessionCleaner = nil

    Camera.CameraType = Enum.CameraType.Custom
    Camera.CameraSubject = Character
    UserInputService.MouseBehavior = Enum.MouseBehavior.Default

    self:Move(0)

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)
    self.Stats = stats
    self.Speed = stats.Speed
    self.MinSpeed = stats.MinimumSpeed or -1
    self.MaxSpeed = stats.MaximumSpeed or 1
    self.IdleSpeed = stats.IdleSpeed or 0

    self.SteeringVector = Vector2.new(0, self.IdleSpeed)

    self.DeltaSteer = 0
	self.TurnSpeedMax = stats.TurnSpeedMax
	self.TurnSpeedRate = stats.TurnSpeedRate
end

function LandVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(LandVehicle)

return LandVehicle