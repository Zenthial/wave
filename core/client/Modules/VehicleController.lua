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
end

return VehicleController