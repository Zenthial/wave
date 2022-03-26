local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local wcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("wcs"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

local computePath = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Helper"):WaitForChild("computePath"))
local inLineOfSight = require(ServerScriptService:WaitForChild("Server"):WaitForChild("Helper"):WaitForChild("inLineOfSight"))

type ClosestPlayerArray = {
    Player: Player,
    Distance: number
}

local BaseEnemy = {}
BaseEnemy.__index = BaseEnemy
BaseEnemy.Name = "BaseEnemy"
BaseEnemy.Tag = "BaseEnemy"
BaseEnemy.Ancestor = workspace
BaseEnemy.Needs = {"Cleaner"}

function BaseEnemy.new(root: Model)
    return setmetatable({
        Root = root,
        Humanoid = root:WaitForChild("Humanoid") :: Humanoid,
        
        CanMove = true,
        MovementLoopActive = false,
        WalkDelay = false,

        CanTarget = true,
        TargetLoopActive = false,
        RandomTarget = false, -- if false, defaults to closest, if true, gets a random
        CurrentTarget = nil,
        DistanceFromTarget = math.huge,

        Signals = {
            DistanceFromTarget = Signal.new() -- fires each time the target distance updates
        }
    }, BaseEnemy)
end

function BaseEnemy:Start()
    task.spawn(self.TargetLoop, self)
    task.spawn(self.MovementLoop, self)
end

function BaseEnemy:MovementLoop()
    self.MovementLoopActive = true
    while self.CanMove do
        -- convert health to use health component, as well as handling stunned
        if self.CurrentTarget ~= nil and self.Humanoid ~= nil and self.Humanoid.Health > 0 then
            local success, path = computePath(self.Root.HumanoidRootPart.Position, self.CurrentTarget.Character.HumanoidRootPart.Position)
            if success then
                local pathTarget = self.CurrentTarget
                -- start walk animation
                for _, pathWaypoint in pairs(path) do
                    if self.CurrentTarget == nil or self.CurrentTarget ~= pathTarget then break end

                    self.Humanoid:MoveTo(pathWaypoint.Position)
                    if pathWaypoint.Action == Enum.PathWaypointAction.Jump then self.Humanoid.Jump = true end
                    
                    if self.WalkDelay == true then
                        task.wait()
                    end
                end
                -- stop walk animation
            end
        else
            task.wait(0.1)
        end
    end
    self.MovementLoopActive = false
end

-- potential index nil error here
function BaseEnemy:GetDistance(target): number
    return (self.Root.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
end

function BaseEnemy:GetSortedClosestPlayers(): {[number]: ClosestPlayerArray}
    local closestPlayers = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character ~= nil and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Parent == workspace and inLineOfSight(self.Root, player) then
            table.insert(closestPlayers, {Player = player, Distance = self:GetDistance(player.Character)})
        end
    end

    table.sort(closestPlayers, function(a, b)
        return a.Distance < b.Distance
    end)

    return closestPlayers
end

function BaseEnemy:UpdateDistance()
    self.DistanceFromTarget = self:GetDistance(self.CurrentTarget.Character)
    self.Signals.DistanceFromTarget:Fire(self.DistanceFromTarget)
end

-- needs to avoid invisible players at some point
-- primary refactor candidate
function BaseEnemy:TargetLoop()
    self.TargetLoopActive = true
    while self.CanTarget do
        local targetablePlayers = self:GetSortedClosestPlayers()
        if targetablePlayers == nil or #targetablePlayers == 0 then task.wait(1) continue end
        if self.RandomTarget then
            if self.CurrentTarget == nil then
                math.randomseed(tick())
                local chosenPlayer = targetablePlayers[math.random(1, #targetablePlayers)]
                -- we guarantee that this player is not nil and that they have a hrp in the closest code
                self.CurrentTarget = chosenPlayer
                self:UpdateDistance()
            else
                if self.CurrentTarget:FindFirstChild("HumanoidRootPart") and self.Root:FindFirstChild("HumanoidRootPart") then
                    self:UpdateDistance()
                else
                    self.CurrentTarget = nil
                end
            end
        else -- get the closest target
            local chosenPlayer = targetablePlayers[1].Player
            if self.CurrentTarget == nil then
                self.CurrentTarget = chosenPlayer
                self:UpdateDistance()
            else
                if self.CurrentTarget:FindFirstChild("HumanoidRootPart") and self.Root:FindFirstChild("HumanoidRootPart") and self.CurrentTarget == chosenPlayer then
                    self:UpdateDistance()
                else
                    self.CurrentTarget = nil
                end
            end
        end
    
        task.wait(.5)
    end
    self.TargetLoopActive = false
end

function BaseEnemy:SetCanMove(bool: boolean)
    self.CanMove = bool
end

function BaseEnemy:SetCanTarget(bool: boolean)
    self.CanTarget = bool
end

function BaseEnemy:SetRandomTarget(bool: boolean)
    self.RandomTarget = bool
end

function BaseEnemy:Destroy()
    self.Cleaner:Clean()
end

wcs.create_component(BaseEnemy)

return BaseEnemy