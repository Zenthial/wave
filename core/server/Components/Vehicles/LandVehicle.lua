local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local VehicleStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("VehicleStats"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, Player: Player, ...any) -> (),
    SendTo: (Courier_T, Port: string, Players: {Player}, ...any) -> ()
}

type LandVehicle_T = {
    __index: LandVehicle_T,
    Name: string,
    Tag: string,
    Root: {
        Chassis: Model & {
            VehicleSeat: VehicleSeat,
            Engine: Part & {
                BodyAngularVelocity: BodyAngularVelocity,
                BodyGyro: BodyGyro,
                BodyVelocity: BodyVelocity
            }
        },
    },
    FlipDebounce: boolean,

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
    assert(bodyVelocity, "No velocity for ".. self.Root.Name)
    self.BodyAngularVelocity = bodyAngularVelocity
    self.BodyVelocity = bodyVelocity
    self.BodyGyro = bodyGyro
    self.OccupantPlayer = nil

    local mainTurret = self.Root:FindFirstChild("Turret")
    if mainTurret ~= nil and self.Root:GetAttribute("DriverMansTurret") == nil then -- if it has a main turret and no variable saying the driver shouldnt get it, then give it to them
        self.Root:SetAttribute("DriverMansTurret", true)
    end
    local driverMansMainTurret = self.Root:GetAttribute("DriverMansTurret") or false

    self:InitializeDriverProximityPrompt()

    local vehicleStats = VehicleStats[self.Root.Name]
    assert(vehicleStats, "No Vehicle Stats for "..self.Root.Name)
    self.Root:SetAttribute("DefaultHealth", vehicleStats.DefaultHealth or 1000)
    self.Root:SetAttribute("RegenSpeed", vehicleStats.RegenSpeed or 0)
    self.Root:SetAttribute("RegenRate", vehicleStats.RegenRate or 0)
    
    CollectionService:AddTag(self.Root, "ObjectHealth")
    local health = tcs.get_component(self.Root, "ObjectHealth")
    
    self.Cleaner:Add(self.Root:GetAttributeChangedSignal("Health"):Connect(function()
        local currentHealth = self.Root:GetAttribute("Health")
        -- do some fancy stuff to reflect visual health changes
    end))

    local vehicleSeatComponent = tcs.get_component(self.Root.Chassis.VehicleSeat, "VehicleSeat")
    self.Cleaner:Add(vehicleSeatComponent.Events.OccupantChanged:Connect(function(newOccupant, oldOccupant)
        if self:IsVehicleFlipped() then
            bodyGyro.MaxTorque = Vector3.new(0, 0, 25000000)
            repeat
                task.wait()
            until not self:IsVehicleFlipped()
            
            task.wait(0.2)
            bodyGyro.MaxTorque = Vector3.new(0, 0, 0)
        end

        if newOccupant ~= nil then
            self.Courier:Send("BindToVehicle", newOccupant, self.Root)

            if mainTurret ~= nil and driverMansMainTurret == true then
                self.Courier:Send("BindToTurret", newOccupant, mainTurret)
            end
        else
            self.ProximityPrompt.Enabled = true   
            self.Courier:Send("UnbindFromVehicle", oldOccupant, self.Root)

            if mainTurret ~= nil and driverMansMainTurret == true then
                self.Courier:Send("UnbindFromTurret", oldOccupant, mainTurret)
            end
        end
    end))
end

function LandVehicle:InitializeDriverProximityPrompt()
    local prompt = Instance.new("ProximityPrompt")
    prompt.Enabled = true
    prompt.ClickablePrompt = true
    prompt.ObjectText = "Driver Seat"
    prompt.ActionText = "Drive the " .. self.Root.Name
    prompt.KeyboardKeyCode = Enum.KeyCode.E
    prompt.MaxActivationDistance = 25
    prompt.HoldDuration = 1
    prompt.RequiresLineOfSight = false

    self.Cleaner:Add(prompt.Triggered:Connect(function(player: Player)
        if self.OccupantPlayer == nil and player.Character ~= nil and player.Character.Humanoid ~= nil then
            local hum = player.Character.Humanoid
            if hum.Sit == true then return end
            self.OccupantPlayer = player
            prompt.Enabled = false
            self.Root.Chassis.VehicleSeat:Sit(hum)
        end
    end))

    prompt.Parent = self.Root.Chassis.Hatch
    self.ProximityPrompt = prompt
end

function LandVehicle:IsVehicleFlipped()
    return (self.Root.Chassis.VehicleSeat.CFrame * CFrame.Angles(math.pi/2,0,0)).LookVector.Y < 0.2        
end

function LandVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(LandVehicle)

return LandVehicle
