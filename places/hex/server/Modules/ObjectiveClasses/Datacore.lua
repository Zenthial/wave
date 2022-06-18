local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Welder = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Welder"))

local Assets = ReplicatedStorage:WaitForChild("Assets") :: Folder
local DatacoreModel = Assets:WaitForChild("ObjectiveModels"):WaitForChild("Datacore") :: Model

local DISTANCE = 5

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Datacore_T = {
    __index: Datacore_T,
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
        MessageChanged: typeof(Signal),
        MarkerChanged: typeof(Signal),
        Ended: typeof(Signal),
    },

    Cleaner: Cleaner_T
}

local Datacore: Datacore_T = {}
Datacore.__index = Datacore

function Datacore.new(root: any)
    return setmetatable({
        Root = root, -- root is the map

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
        }
    }, Datacore)
end

function Datacore:Start()
    self.Cleaner = Trove.new()

    local point = self.Root.Objectives:FindFirstChild("Hill") :: BasePart
    if not point then error("Hill does not exist on map " .. self.Root.Name) end

    self.Point = point
    self:SpawnModel(point.CFrame)

    local _detectCleaner = self:CreateDetection()
end

function Datacore:SpawnModel(position: CFrame)
    if self.Model then
        self.Model:Destroy()
    end

    local model = DatacoreModel:Clone() :: Model & { Handle: BasePart }
    model:SetPrimaryPartCFrame(position)
    model.Parent = workspace
    model:SetAttribute("Owner", "Neutral")
    self.Events.OwnershipChanged:Fire({D = "Neutral"})

    self.Model = model
end

function Datacore:CreateDetection()
    local cleaner = Trove.new()

    local active = true
    while active do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if (hrp.Position - self.Model.Handle.Position).Magnitude <= DISTANCE then
                    self:Equip(player)
                    cleaner:Clean()
                    break
                end
            end
        end

        task.wait(0.25)
    end

    cleaner:Add(function()
        active = false
    end)

    return cleaner
end

function Datacore:WeldModelToPlayer(player: Player)
    self.Model:Destroy()

    local model = DatacoreModel:Clone()
    model.Parent = player.Character
    model:SetAttribute("Owner", player.Team.Name)
    self.Events.OwnershipChanged:Fire({D = player.Team.Name})

    Welder:WeldDatacore(player.Character, model)

    self.Model = model
end

function Datacore:PointsHandler()
    local pointsCleaner = Trove.new()
    local active = true

    task.spawn(function()
        while active do
            if self.Model and self.Model:GetAttribute("Owner") ~= "Neutral" then
                if self.Points[self.Model:GetAttribute("Owner")] == nil then self.Points[self.Model:GetAttribute("Owner")] = 0 end
                self.Points[self.Model:GetAttribute("Owner")] += 1
                self.Events.PointsChanged:Fire(self.Points)
            end
            task.wait(1)
        end
    end)

    pointsCleaner:Add(function()
        active = false
    end)

    return pointsCleaner
end

function Datacore:Equip(player: Player)
    if player:GetAttribute("Dead") == false then
        self:WeldModelToPlayer(player)
        local equipCleaner = Trove.new()

        equipCleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            self:SpawnModel(self.Point.CFrame)
            self:CreateDetection()
        end))

        equipCleaner:Add(self:PointsHandler(), "Clean")
    else
        self:SpawnModel(self.Point.CFrame)
        self:CreateDetection()
    end
end

function Datacore:Destroy()
    self.Cleaner:Clean()
end

return Datacore