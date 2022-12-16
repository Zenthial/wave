local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"):WaitForChild("GenericTypes"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))
local MasterClock = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Clock"))

local FIX_HANS_ANGLE = CFrame.Angles(0, math.rad(-180), math.rad(90))
local LOOP_DELAY = 0.5

type Cleaner_T = types.Cleaner_T

type Courier_T = types.Courier_T

type Hans_T = {
    __index: Hans_T,
    Name: string,
    Tag: string,
    Direction: string | nil,
    ActiveTween: Tween,
    RootPart: Part,

    PositiveNode: Part, -- The PositiveNode is the next node towards the WIJ objective, otherwise known as towards the Raider spawn
    NegativeNode: Part, -- The NegativeNode is the next node towards the Raider objective, otherwise known as towards the WIJ spawn
    CurrentNode: Part, -- The CurrentNode is the node that Hans last reached. At the start, it is the node in the middle of the map
    CurrentProgress: number, -- number from -1 <-> 1. The progress towards the next node. At the start, it is 0. When it reaches 1, the CurrentNode is set to the PositiveNode and the PositiveNode is set to the CurrentNode
    Cleaner: Cleaner_T,
    Courier: Courier_T
}

local Hans: Hans_T = {}
Hans.__index = Hans
Hans.Name = "Hans"
Hans.Tag = "Hans"
Hans.Ancestor = game

function Hans.new(root: any)
    return setmetatable({
        Root = root,
        Direction = nil,
        Active = false,

        ActiveTween = nil,

        PositiveNode = nil, 
        NegativeNode = nil,
        CurrentNode = nil,
        LerpFraction = 0,
        CurrentProgress = 0,
    }, Hans)
end

function Hans:Start()
    local rootPart = self.Root:WaitForChild("TorsoJoint")
    self.RootPart = rootPart

    local nodes = workspace:WaitForChild("Map"):WaitForChild("Nodes")
    self.Nodes = nodes

    self.CurrentNode = self.Nodes:FindFirstChild("3")
	self.NextNode = self.Nodes:FindFirstChild("4")
	self.PayloadAngle = CFrame.new(self.CurrentNode.Position, self.NextNode.Position)
	self.PayloadAngle -= self.PayloadAngle.Position

    assert(self.CurrentNode ~= nil and self.NextNode ~= nil, "Need at least two nodes for a payload to work")
    self.CurrentCFrame = CFrame.new(self.CurrentNode.Position) * FIX_HANS_ANGLE
    self.MaxDistance = self:GetTotalDistance()
    self.CurrentDistance = 0
    self.Root:SetPrimaryPartCFrame(self.CurrentCFrame)

    self:RuntimeLoop()
end

function Hans:GetTotalDistance(): number
    local totalDist = 0
    -- -1 because we don't need to calculate the last node
    for i = 1, #self.Nodes:GetChildren() - 1 do
        local first = self.Nodes:FindFirstChild(tostring(i))
        local second = self.Nodes:FindFirstChild(tostring(i+1))

        if first and second then
            totalDist += (first.Position - second.Position).Magnitude
        end
    end

    return totalDist
end

function Hans:GetCurrentDistance(): number
    local currentDistance = 0

    for i = 1, #self.Nodes:GetChildren() - 1 do
        local first = self.Nodes:FindFirstChild(tostring(i))
        local second = self.Nodes:FindFirstChild(tostring(i+1))

        if first and second and first ~= self.CurrentNode then
            currentDistance += (first.Position - second.Position).Magnitude
        elseif first and second and first == self.CurrentNode then
            currentDistance += (first.Position - self.Root.PrimaryPart.Position).Magnitude
            break
        end
    end

    return currentDistance
end

-- Get players within the payload
function Hans:GetPlayers(): {Player}
    local players: {Player} = {}
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        if char ~= nil and char:FindFirstChild("HumanoidRootPart") ~= nil then
            local rootPos = char.HumanoidRootPart.Position
            local primaryPos = self.Root.PrimaryPart.Position

             if (rootPos - primaryPos).Magnitude <= 30 then
                table.insert(players, player)
            end
        end
    end

    return players
end

-- returns attackers and defenders
function Hans:CalculateDirection(): number
    local playersNearPayload = self:GetPlayers()
    local defenders, attackers = 0,0
    for _, player in pairs(playersNearPayload) do
        if player.TeamColor == BrickColor.new("Bright blue") then
            defenders += 1
        elseif player.TeamColor == BrickColor.new("Bright red") then
            attackers += 1
        end
    end

    if defenders > attackers then
        self.Direction = "Backward"
    elseif defenders < attackers then
        self.Direction = "Forward"
    else
        self.Direction = nil
    end

    return attackers, defenders
end

-- update the current node, ensure the payload starts from the correct position
function Hans:UpdateNode()
    if self.Direction ~= nil then
        local dir = self.Direction
        local currentNode, nextNode = self.CurrentNode, self.NextNode

        if dir == "Forward" then
            local newNextNode = self.Nodes:FindFirstChild(tostring(tonumber(nextNode.Name) + 1))
            self.CurrentNode = nextNode
			self.NextNode = newNextNode

            self.LerpFraction = 0
            
            if newNextNode == nil then
                self.CurrentNode = currentNode
			    self.NextNode = nextNode
                self:Stop(1)
            else
                self.PayloadAngle = CFrame.new(self.CurrentNode.Position, self.NextNode.Position)
			    self.PayloadAngle -= self.PayloadAngle.p
            end           
        elseif dir == "Backward" then
            local newCurrentNode = self.Nodes:FindFirstChild(tostring(tonumber(currentNode.Name) - 1))
            self.CurrentNode = newCurrentNode
			self.NextNode = currentNode
            
            if newCurrentNode == nil then
                -- at the start of the track
                self.LerpFraction = 0
                self:Stop(-1)
                self.CurrentNode = currentNode
				self.NextNode = nextNode
            else
                self.LerpFraction = 1
                self.PayloadAngle = CFrame.new(self.NextNode.Position, self.CurrentNode.Position)
			    self.PayloadAngle -= self.PayloadAngle.p
            end
        end
    end
end

function Hans:RuntimeLoop()
    task.spawn(function()
        self.Active = true
    
        while self.Active do
            self.Root:SetPrimaryPartCFrame(self.CurrentCFrame)
            local attackers, defenders = self:CalculateDirection()
            
            if self.Direction ~= nil then
                self.CurrentDistance = self:GetCurrentDistance()
                local playerNums = attackers - defenders
                self.LerpFraction += playerNums/12
                
				local dir = self.Direction

				local needsUpdate = false
				if dir == "Forward" then
					if self.LerpFraction >= 1 or math.abs(self.LerpFraction - 1) <= 1e-6 then
						self.LerpFraction = self.LerpFraction >= 1 and 1 or 0
						needsUpdate = true
					end
					
				    local lerp = self.CurrentNode.CFrame:Lerp(self.NextNode.CFrame, self.LerpFraction)
				    self.CurrentCFrame = CFrame.new(lerp.Position) * self.PayloadAngle * FIX_HANS_ANGLE
                    courier:SendToAll("HansAnimate", self.CurrentCFrame, MasterClock:GetTime(), LOOP_DELAY)
				elseif dir == "Backward" then
					if self.LerpFraction <= 0 or math.abs(self.LerpFraction) <= 1e-6 then
                        self.LerpFraction = 0
						needsUpdate = true
					end
					
				    local lerp = self.CurrentNode.CFrame:Lerp(self.NextNode.CFrame, self.LerpFraction)
					self.CurrentCFrame = CFrame.new(lerp.Position) * self.PayloadAngle * FIX_HANS_ANGLE
                    courier:SendToAll("HansAnimate", self.CurrentCFrame, MasterClock:GetTime(), LOOP_DELAY)
				end

				if needsUpdate then
					self:UpdateNode()
				end
            end

            if self.Active then
                courier:SendToAll("HansUI", MasterClock:GetTime(), LOOP_DELAY, attackers, defenders, self.CurrentDistance, self.MaxDistance)
            end

            task.wait(LOOP_DELAY)
        end
    end)
end

function Hans:Stop(winner: number)
    self.Active = false
    self.Root:SetPrimaryPartCFrame(self.CurrentCFrame)
    if winner == 1 then
        courier:SendToAll("HansWin", winner) 
    elseif winner == -1 then
        courier:SendToAll("HansWin", winner)
    end
end
-- function Hans:Move()
--     print(self.Direction)
--     if self.Direction == 1 then
--         self.CurrentProgress += LERP_AMOUNT
--         local goalCFrame = self.RootPart.CFrame:Lerp(self.PositiveNode.CFrame, self.CurrentProgress)
--         print(goalCFrame)
--         self.RootPart.CFrame = goalCFrame
--     elseif self.Direction == -1 then
--         self.CurrentProgress -= LERP_AMOUNT
--         local goalCFrame = self.RootPart.CFrame:Lerp(self.NegativeNode.CFrame, self.CurrentProgress)
--         print(goalCFrame)
--         self.RootPart.CFrame = goalCFrame
--     end

--     local nodes = workspace:WaitForChild("Map"):WaitForChild("Nodes")
--     if self.CurrentProgress == 1 then
--         self.CurrentNode = self.PositiveNode
--         local nodeNum = tonumber(self.CurrentNode.Name:sub(5))
--         local nextNode = nodes:WaitForChild("Node" .. tostring(nodeNum + 1))
--         if nextNode ~= nil then
--             self.PositiveNode = nextNode
--         else
--             -- hans has reached the end of the map, wij wins
--         end
--     elseif self.CurrentProgress == -1 then
--         self.CurrentNode = self.NegativeNode
--         local nodeNum = tonumber(self.CurrentNode.Name:sub(5))
--         local nextNode = nodes:WaitForChild("Node" .. tostring(nodeNum - 1))
--         if nextNode ~= nil then
--             self.NegativeNode = nextNode
--         else
--             -- hans has reached the end of the map, raiders win
--         end
--     end
-- end

function Hans:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Hans)

return Hans