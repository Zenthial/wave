local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))

local Hill = ServerStorage:WaitForChild("Hill") :: Part & {Mesh: SpecialMesh}

local GenericPoint = require(script.Parent.GenericPoint) :: {Start: () -> (), Events: {
    OwnerChanged: typeof(Signal)
}}

local function createPointParts(self)
    local pointAPart = Hill:Clone()
    pointAPart.Transparency = 0.25
    pointAPart.Position = self.Root.Objectives.PointA.Position
    pointAPart.Parent = self.Root

    local pointBPart = Hill:Clone()
    pointBPart.Transparency = 0.25
    pointBPart.Position = self.Root.Objectives.PointB.Position
    pointBPart.Parent = self.Root

    local pointCPart = Hill:Clone()
    pointCPart.Transparency = 0.25
    pointCPart.Position = self.Root.Objectives.PointC.Position
    pointCPart.Parent = self.Root

    return pointAPart, pointBPart, pointCPart
end

local ObjectiveColors = {
    Red = Color3.fromRGB(235, 28, 10),
    Blue = Color3.fromRGB(18, 141, 235),
    Neutral = Color3.fromRGB(137, 137, 137)
}

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Domination_T = {
    __index: Domination_T,
    Name: string,
    Tag: string,
    Model: Model & { Handle: BasePart },

    Points: {
        Red: number,
        Blue: number,
    },

    Events: {
        PointsChanged: typeof(Signal),
        OwnershipChanged: typeof(Signal),
        MessageSignal: typeof(Signal),
        MarkerSignal: typeof(Signal),
        Ended: typeof(Signal),
    },

    Cleaner: Cleaner_T
}

local Domination: Domination_T = {}
Domination.__index = Domination

function Domination.new(root: any)
    return setmetatable({
        Root = root, -- root is the map

        Active = false,

        Points = {
            Red = 0,
            Blue = 0,
        },

        Events = {
            PointsChanged = Signal.new(),
            OwnershipChanged = Signal.new(),
            MessageSignal = Signal.new(),
            MarkerSignal = Signal.new(),
            Ended = Signal.new(),
        },

        Cleaner = Trove.new()
    }, Domination)
end

function Domination:Start()
    local pointAPart, pointBPart, pointCPart = createPointParts(self)

    local points = { PointA = GenericPoint.new(pointAPart), PointB = GenericPoint.new(pointBPart), PointC = GenericPoint.new(pointCPart) }

    local pointOwners = {
        PointA = "Neutral",
        PointB = "Neutral",
        PointC = "Neutral",
    }

    for pointName, pointClass: typeof(GenericPoint) in points do
        self.Cleaner:Add(pointClass.Events.OwnerChanged:Connect(function(owner: string)
            pointOwners[pointName] = owner
            pointClass.Root.Color = ObjectiveColors[owner]
    
            self.Events.OwnershipChanged:Fire(pointOwners)
        end))

        pointClass:Start()
    end

    self.Active = true
    task.spawn(function()
        while self.Active do
            for pointName, pointOwner in pointOwners do
                if pointOwner ~= "Neutral" then
                    self.Points[pointOwner] += 1
                    self.Events.PointsChanged:Fire(self.Points)
    
                    if self.Points[pointOwner] >= ObjectiveConfigurations.ModeInfo.Hardpoint.MaxScore then
                        self.Events.Ended:Fire(pointOwner)
                        self.Cleaner:Clean()
                        break
                    end
                end
            end
            
            task.wait(1)
        end
    end)
end

function Domination:Destroy()
    self.Cleaner:Clean()
end

return Domination