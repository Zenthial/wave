local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type PlaneThruster_T = {
    __index: PlaneThruster_T,
    Name: string,
    Tag: string,

    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local PlaneThruster: PlaneThruster_T = {}
PlaneThruster.__index = PlaneThruster
PlaneThruster.Name = "PlaneThruster"
PlaneThruster.Tag = "PlaneThruster"
PlaneThruster.Ancestor = game

function PlaneThruster.new(root: any)
    return setmetatable({
        Root = root,
    }, PlaneThruster)
end

function PlaneThruster:Start()
    print("We even running?")
    local plane = self:FindPlane(self.Root)
    if not plane then return end

    self.Plane = plane
    self:UpdateThruster()

    self.Cleaner:Add(plane:GetAttributeChangedSignal("Flying"):Connect(function()
        self:UpdateThruster()
    end))
end

function PlaneThruster:UpdateThruster()
    local vehicleToggle = self.Plane:GetAttribute("Flying")
    if vehicleToggle then
        self.Root.Transparency = 0
    else
        self.Root.Transparency = 1
    end
end

function PlaneThruster:FindPlane(part: any) : BasePart | nil
    if CollectionService:HasTag(part, "AirVehicle") then
        return part
    elseif part.Name == "Workspace" then
        return nil
    else
        return self:FindPlane(part.Parent)
    end
end

function PlaneThruster:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(PlaneThruster)

return PlaneThruster