local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local terrainParams = RaycastParams.new()
terrainParams.FilterDescendantsInstances = { workspace.Terrain }
terrainParams.FilterType = Enum.RaycastFilterType.Whitelist

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local function setMassless(model: Model, bool: boolean)
    assert(model and model:IsA("Model"), "Model argument of setMassless must be a model.");
    
    for i, v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            local part = v :: BasePart
            part.Massless = bool
        end
    end
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type Boat_T = {
    __index: Boat_T,
    Name: string,
    Tag: string,
    Root: Model & {
        VehicleSeat: VehicleSeat,
        Base: Part & {
            Attachment: Attachment,
            AlignOrientation: AlignOrientation,
            VectorForce: VectorForce,
            LinearVelocity: LinearVelocity,
            AngularVelocity: AngularVelocity,
        }
    },

    Seat: VehicleSeat,
    LinearVelocity: LinearVelocity,
    AngularVelocity: AngularVelocity,
    AlignOrientation: AlignOrientation,

    CurrentSpeed: number,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Boat: Boat_T = {}
Boat.__index = Boat
Boat.Name = "Boat"
Boat.Tag = "Boat"
Boat.Ancestor = game

function Boat.new(root: any)
    return setmetatable({
        Root = root,
    }, Boat)
end

function Boat:Start()
    self.Seat = self.Root.VehicleSeat
    self.LinearVelocity = self.Root.Base.LinearVelocity
    self.AngularVelocity = self.Root.Base.AngularVelocity
    self.AlignOrientation = self.Root.Base.AlignOrientation

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)
    self.Stats = stats
    self.Speed = stats.Speed
    self.CurrentSpeed = 0

    self:TrackOccupants()
end

function Boat:OnWater(): boolean
    local startPosition = self.Root.Base.Position + Vector3.new(0, 5, 0)
    local endPosition = self.Root.Base.Position - Vector3.new(0, 15, 0)

    local ray = workspace:Raycast(startPosition, endPosition, terrainParams)
    return if ray then ray.Material == Enum.Material.Water else false
end

function Boat:Move(direction: number)
    self.LinearVelocity.VectorVelocity = self.Seat.CFrame.LookVector * direction

    self.AlignOrientation.Enabled = direction == 0
    self.AngularVelocity.Enabled = not (direction == 0)
    self.AngularVelocity.AngularVelocity = Vector3.new(0, -1 * self.Seat.SteerFloat, 0)
end

function Boat:RunServiceLoop()
    -- if not self:OnWater() then
    --     self:Move(0)
        
    --     return
    -- end

    local velocity = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        velocity += 1
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        velocity -= 1
    end

    self:Move(self.Speed * velocity)
end

-- finds every single non-vehicle seat on a boat, listens to people entering and exiting, updates VectorForce based on that
function Boat:TrackOccupants()
    for _, thing in pairs(self.Root:GetChildren()) do
        if thing:IsA("Seat") then
            local seat = thing :: Seat
            
            local occupantCharacter = nil
            self.Cleaner:Add(seat.Changed:Connect(function(property: string)
                if property == "Occupant" then
                    local newOccupant = seat.Occupant
                    if newOccupant ~= nil then
                        occupantCharacter = newOccupant.Parent
                        setMassless(occupantCharacter, true)
                    else
                        setMassless(occupantCharacter, false)
                        occupantCharacter = nil
                    end
                end
            end))
        end
    end
end

function Boat:Bind()
    local currentVectorForce = self.Root.Base.VectorForce.Force
    local occupantMass = setMassless(Character, true)
    self.Root.Base.VectorForce.Force = currentVectorForce + Vector3.new(0, occupantMass, 0)
        
    local sessionCleaner = Trove.new()
    self.Cleaner:Add(sessionCleaner, "Clean")
    self.SessionCleaner = sessionCleaner

    self:Move(0)

    sessionCleaner:Add(RunService.RenderStepped:Connect(function()
        self:RunServiceLoop()
    end))
end

function Boat:Unbind()
    local currentVectorForce = self.Root.Base.VectorForce.Force
    local occupantMass = setMassless(Character, false)
    self.Root.Base.VectorForce.Force = currentVectorForce - Vector3.new(0, occupantMass, 0)
        
    self.SessionCleaner:Clean()
    self.SessionCleaner = nil

    local stats = VehicleStats[self.Root.Name]
    assert(stats, "No vehicle stats for " .. self.Root.Name)
    self.Stats = stats
    self.Speed = stats.Speed

    self.AlignOrientation.Enabled = true
    self.AngularVelocity.Enabled = false
end

function Boat:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Boat)

return Boat