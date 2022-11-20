local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))

local Hill = ServerStorage:WaitForChild("Hill") :: Part & {Mesh: SpecialMesh}

local GenericPoint = require(script.Parent.GenericPoint) :: {Start: () -> (), Events: {
    OwnerChanged: typeof(Signal)
}}

local ObjectiveColors = {
    Red = Color3.fromRGB(235, 28, 10),
    Blue = Color3.fromRGB(18, 141, 235),
    Neutral = Color3.fromRGB(137, 137, 137)
}

local HARDPOINT_COOLDOWN = 60

local function shuffle(t: {any}): {any}
    math.randomseed(os.time())
    local tbl = {}
    for i = 1, #t do
        tbl[i] = t[i]
    end
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Hardpoint_T = {
    __index: Hardpoint_T,
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

local Hardpoint: Hardpoint_T = {}
Hardpoint.__index = Hardpoint

function Hardpoint.new(root: any)
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
    }, Hardpoint)
end

function Hardpoint:Start()
    local points = {"PointA", "PointB", "PointC"}
    local currentOwner = "Neutral"

    local shuffledPoints = shuffle(points)
    local currentPoint = shuffledPoints[1]

    local hillPoint = Hill:Clone()
    hillPoint.Transparency = 0.25
    hillPoint.Position = self.Root.Objectives[currentPoint].Position
    hillPoint.Parent = self.Root

    self.Events.MarkerSignal:Fire(hillPoint, "Hill")


    local point = GenericPoint.new(hillPoint)
    self.Cleaner:Add(point.Events.OwnerChanged:Connect(function(owner: string)
        currentOwner = owner
        hillPoint.Color = ObjectiveColors[owner]

        self.Events.OwnershipChanged:Fire({A = currentOwner})
        self.Events.MessageSignal:Fire(string.upper("Point captured by " .. owner))
    end))
    point:Start()

    self.Active = true
    task.spawn(function()
        while self.Active do
            if currentOwner ~= "Neutral" then
                self.Points[currentOwner] += 1
                self.Events.PointsChanged:Fire(self.Points)

                if self.Points[currentOwner] >= ObjectiveConfigurations.ModeInfo.Hardpoint.MaxScore then
                    self.Events.Ended:Fire(currentOwner)
                    self.Cleaner:Clean()
                end
            end
            
            task.wait(1)
        end
    end)

    task.spawn(function()
        while self.Active do
            task.wait(HARDPOINT_COOLDOWN)
            local shuffledPoints = shuffle(points)
            local chosenPoint = if shuffledPoints[1] == currentPoint then shuffledPoints[2] else shuffledPoints[1]
            currentPoint = chosenPoint

            self.Events.MessageSignal:Fire("POINT MOVING!")
            hillPoint.Position = self.Root.Objectives[chosenPoint].Position
            point:SetOwner("Neutral")
        end
    end)

    self.Cleaner:Add(function()
        self.Active = false
    end)
end

function Hardpoint:Destroy()
    self.Cleaner:Clean()
end

return Hardpoint