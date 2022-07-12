local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local VehicleController = {}

function VehicleController:Start()
    Courier:Listen("BindToVehicle"):Connect(function(vehicle: Model)
        if CollectionService:HasTag(vehicle, "LandVehicle") then
            local landVehicleComponent = tcs.get_component(vehicle, "LandVehicle")
            landVehicleComponent:Bind()
        end
    end)

    Courier:Listen("UnbindFromVehicle"):Connect(function(vehicle: Model)
        if CollectionService:HasTag(vehicle, "LandVehicle") then
            local landVehicleComponent = tcs.get_component(vehicle, "LandVehicle")
            landVehicleComponent:Unbind()
        end
    end)

    Courier:Listen("BindToPlane"):Connect(function(vehicle: Model)
        if CollectionService:HasTag(vehicle, "AirVehicle") then
            local airVehicleComponent = tcs.get_component(vehicle, "AirVehicle")
            airVehicleComponent:Bind()
        end
    end)

    Courier:Listen("UnbindFromPlane"):Connect(function(vehicle: Model)
        if CollectionService:HasTag(vehicle, "AirVehicle") then
            local airVehicleComponent = tcs.get_component(vehicle, "AirVehicle")
            airVehicleComponent:Unbind()
        end
    end)

    Courier:Listen("BindToTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "Turret") then
            local turretComponent = tcs.get_component(turret, "Turret")
            turretComponent:Bind(true)
        end
    end)

    Courier:Listen("UnbindFromTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "Turret") then
            local turretComponent = tcs.get_component(turret, "Turret")
            turretComponent:Unbind()
        end
    end)

    Courier:Listen("BindToMountedTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "MountedTurret") then
            local turretComponent = tcs.get_component(turret, "MountedTurret")
            turretComponent:Bind()
        end
    end)

    Courier:Listen("UnbindFromMountedTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "MountedTurret") then
            local turretComponent = tcs.get_component(turret, "MountedTurret")
            turretComponent:Unbind()
        end
    end)

    Courier:Listen("UpdateServo"):Connect(function(servo: HingeConstraint, angle: number)
        servo.TargetAngle = angle
    end)
end

return VehicleController