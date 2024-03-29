local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Welder = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Welder"))
local ObjectiveConfigurations = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("ObjectiveConfigurations"))

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
        MessageSignal: typeof(Signal),
        MarkerSignal: typeof(Signal),
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
    self.Events.MarkerSignal:Fire(model, "Datacore")
    self.Events.MessageSignal:Fire(string.upper("Datacore spawned"))
    self.Events.OwnershipChanged:Fire({D = "Neutral"})

    self.Model = model
end

function Datacore:CreateDetection()
    local active = true
    while active do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if (hrp.Position - self.Model.Handle.Position).Magnitude <= DISTANCE then
                    active = false
                    self:Equip(player)
                    break
                end
            end
        end

        task.wait(0.25)
    end
end

function Datacore:WeldModelToPlayer(player: Player)
    self.Model:Destroy()

    local model = DatacoreModel:Clone()
    model.Parent = player.Character
    model:SetAttribute("Owner", player.Team.Name)
    self.Events.MarkerSignal:Fire(model, "Datacore")
    self.Events.MessageSignal:Fire(string.upper("Datacore picked up by ".. player.Name))
    self.Events.OwnershipChanged:Fire({D = player.Team.Name})

    Welder:WeldDatacore(player.Character, model)

    self.Model = model
end

function Datacore:PointsHandler()
    local pointsCleaner = Trove.new()
    local active = true

    task.spawn(function()
        while active do
            local currentOwner = self.Model:GetAttribute("Owner")
            if self.Model and currentOwner ~= "Neutral" then
                if self.Points[currentOwner] == nil then self.Points[currentOwner] = 0 end

                self.Points[currentOwner] += 1
                self.Events.PointsChanged:Fire(self.Points)

                if self.Points[currentOwner] >= ObjectiveConfigurations.ModeInfo.Datacore.MaxScore then
                    self.Events.Ended:Fire(currentOwner)
                    self.Cleaner:Clean()
                end
            end

            task.wait(1)
        end
    end)

    pointsCleaner:Add(function()
        active = false
    end)

    return pointsCleaner
end

function Datacore:CreateHighlight(player: Player): Highlight
    if player.Character then
        local highlight = Instance.new("Highlight")
        highlight.FillColor = BrickColor.new("Gold").Color
        highlight.OutlineColor = BrickColor.new("Gold").Color
        highlight.OutlineTransparency = 0.5
        highlight.FillTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

        highlight.Parent = player.Character
        
        return highlight
    end
end

function Datacore:Equip(player: Player)
    if player:GetAttribute("Dead") == false then
        self:WeldModelToPlayer(player)
        
        local equipCleaner = Trove.new()
        equipCleaner:Add(player:GetAttributeChangedSignal("Dead"):Connect(function()
            equipCleaner:Clean()
            self:SpawnModel(self.Point.CFrame)
            self:CreateDetection()
        end))

        equipCleaner:Add(self:PointsHandler(), "Clean")
        equipCleaner:Add(self:CreateHighlight(player))
    else
        self:SpawnModel(self.Point.CFrame)
        self:CreateDetection()
    end
end

function Datacore:Destroy()
    self.Cleaner:Clean()
end

return Datacore