local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Welder = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Welder"))

local Assets = ReplicatedStorage:WaitForChild("Assets") :: Folder
local ArtifactModel = Assets:WaitForChild("ObjectiveModels"):WaitForChild("Artifact") :: Model

local DISTANCE = 2.5

type Cleaner_T = {
    Add: (Cleaner_T, any) -> (),
    Clean: (Cleaner_T) -> ()
}

type Artifact_T = {
    __index: Artifact_T,
    Name: string,
    Tag: string,
    Model: Model & { Handle: BasePart },

    Points: {
        Red: number,
        Blue: number,
    },

    Events: {
        PointsChanged: typeof(Signal)
    },

    Cleaner: Cleaner_T
}

local Artifact: Artifact_T = {}
Artifact.__index = Artifact
Artifact.Name = "Artifact"
Artifact.Tag = "Artifact"
Artifact.Ancestor = workspace

function Artifact.new(root: any)
    return setmetatable({
        Root = root, -- root is the map

        Points = {
            Red = 0,
            Blue = 0,
        },

        Events = {
            PointsChanged = Signal.new()
        }
    }, Artifact)
end

function Artifact:Start()
    local point = self.Root:FindFirstChild("ArtifactSpawn") :: BasePart
    if not point then error("ArtifactSpawn does not exist on map " .. self.Root.Name) end

    self.Point = point
    self:SpawnModel(point.CFrame)

    local detectCleaner = self:CreateDetection()
end

function Artifact:SpawnModel(position: CFrame)
    if self.Model then
        self.Model:Destroy()
    end

    local model = ArtifactModel:Clone() :: Model & { Handle: BasePart }
    model:SetPrimaryPartCFrame(position)
    model.Parent = workspace
    model:SetAttribute("Owner", "Neutral")

    self.Model = model
end

function Artifact:CreateDetection()
    local cleaner = Trove.new()

    local active = true
    while active do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                if (hrp.Position - self.Model.Handle.Position) <= DISTANCE then
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

function Artifact:WeldModelToPlayer(player: Player)
    self.Model:Destroy()

    local model = ArtifactModel:Clone()
    model.Parent = player.Character
    model:SetAttribute("Owner", player.Team.Name)

    Welder:WeldArtifact(player.Character, model)

    self.Model = model
end

function Artifact:PointsHandler()
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

function Artifact:Equip(player: Player)
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

function Artifact:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Artifact)

return Artifact