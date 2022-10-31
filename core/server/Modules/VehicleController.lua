local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local VehicleController = {}

function VehicleController:Start()
    
    Courier:Listen("ToggleVehicleInteraction"):Connect(function(Player: Player, VehicleModel: Model)
        if not CollectionService:HasTag(VehicleModel, "AirVehicle") or not VehicleModel.PilotSeat or not CollectionService:HasTag(VehicleModel.PilotSeat, "VehicleSeat") then return end
        local isVehicleComponent = tcs.has_component(VehicleModel, "AirVehicle")
        local vehicleSeatComponent = tcs.get_component(VehicleModel.PilotSeat, "VehicleSeat")

        if not isVehicleComponent or not vehicleSeatComponent.Occupant == Player then return end


        VehicleModel:SetAttribute("VehicleInteractToggle", not VehicleModel:GetAttribute("VehicleInteractToggle"))
    end)

    Courier:Listen("VehicleIgnition"):Connect(function(Player: Player, VehicleModel)
        if not CollectionService:HasTag(VehicleModel, "AirVehicle") or not VehicleModel.PilotSeat or not CollectionService:HasTag(VehicleModel.PilotSeat, "VehicleSeat") then return end

        local isVehicleComponent = tcs.has_component(VehicleModel, "AirVehicle")
        local vehicleSeatComponent = tcs.get_component(VehicleModel.PilotSeat, "VehicleSeat")

        if not isVehicleComponent or not vehicleSeatComponent.Occupant == Player then return end

        VehicleModel:SetAttribute("Flying", not VehicleModel:GetAttribute("Flying"))
    end)
end

return VehicleController