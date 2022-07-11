local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

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

    local mainTurret = self.Root:FindFirstChild("Turret")
    if mainTurret ~= nil and self.Root:GetAttribute("DriverMansTurret") == nil then -- if it has a main turret and no variable saying the driver shouldnt get it, then give it to them
        self.Root:SetAttribute("DriversMansTurret", true)
    end
    local driverMansMainTurret = self.Root:GetAttribute("DriverMansTurret") or false

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
            self.Courier:Send("UnbindFromVehicle", oldOccupant, self.Root)

            if mainTurret ~= nil and driverMansMainTurret == true then
                self.Courier:Send("UnbindFromTurret", oldOccupant, mainTurret)
            end
        end
    end))
end

function LandVehicle:IsVehicleFlipped()
    return (self.Root.Chassis.VehicleSeat.CFrame * CFrame.Angles(math.pi/2,0,0)).LookVector.Y < 0.2        
end

function LandVehicle:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(LandVehicle)

return LandVehicle
