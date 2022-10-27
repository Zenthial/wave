-- 10/27/2022/
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Courier_T = {
    Listen: (Courier_T, Port: string) -> {Connect: RBXScriptSignal},
    Send: (Courier_T, Port: string, ...any) -> ()
}

type PlaneDoor_T = {
    __index: PlaneDoor_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local PlaneDoor: PlaneDoor_T = {}
PlaneDoor.__index = PlaneDoor
PlaneDoor.Name = "PlaneDoor"
PlaneDoor.Tag = "PlaneDoor"
PlaneDoor.Ancestor = game

function PlaneDoor.new(root: BasePart)
    return setmetatable({
        Root = root,
    }, PlaneDoor)
end

function PlaneDoor:Start()
    local plane = self:FindPlane(self.Root)
    if not plane then return nil end

    self.Plane = plane
    self:UpdateDoor()

    self.Cleaner:Add(plane:GetAttributeChangedSignal("VehicleInteractToggle"):Connect(function()
        self:UpdateDoor()
    end))
end

function PlaneDoor:UpdateDoor()
    local vehicleToggle = self.Plane:GetAttribute("VehicleInteractToggle")
    self.Root.CanCollide = vehicleToggle
    if vehicleToggle then
        self.Root.Transparency = 0
    else
        self.Root.Transparency = 1
    end
end

function PlaneDoor:FindPlane(part: any) : BasePart | nil
    if CollectionService:HasTag(part, "AirVehicle") then
        return part
    elseif part.Name == "Workspace" then
        return nil
    else
        return self:FindPlane(part.Parent)
    end
end

function PlaneDoor:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(PlaneDoor)

return PlaneDoor