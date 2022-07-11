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

    Courier:Listen("BindToTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "Turret") then
            local turretComponent = tcs.get_component(turret, "Turret")
            turretComponent:Bind()
        end
    end)

    Courier:Listen("UnbindFromTurret"):Connect(function(turret: Model)
        if CollectionService:HasTag(turret, "Turret") then
            local turretComponent = tcs.get_component(turret, "Turret")
            turretComponent:Unbind()
        end
    end)
end

return VehicleController