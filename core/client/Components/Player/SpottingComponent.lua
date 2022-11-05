local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local Player = Players.LocalPlayer

local function recursivelyFindHealthComponent(part: BasePart)
    local player: Player | nil = Players:GetPlayerFromCharacter(part)
    if player ~= nil then
        return player
    elseif part.Parent ~= workspace then 
        return recursivelyFindHealthComponent(part.Parent)
    else
        return nil
    end
end

local SpottingComponent = {}
SpottingComponent.__index = SpottingComponent
SpottingComponent.Ancestor = Players
SpottingComponent.Name = "SpottingComponent"
SpottingComponent.Tag = "Player"

function SpottingComponent.new(root)
    return setmetatable({Root = root}, SpottingComponent)
end

function SpottingComponent:Start()
    print("creating")
    self.MouseComponent = tcs.get_component(Player, "Mouse")
    
    local character = Player.Character or Player.CharacterAdded:Wait()
    self.hrp = character:WaitForChild("HumanoidRootPart")
end

function SpottingComponent:FeedInput()
    local hitPart, position = self.MouseComponent:Raycast(self.hrp.Position) 

    if hitPart ~= nil then
        local spottedPlayer = recursivelyFindHealthComponent(hitPart)

        if spottedPlayer then
            courier:Send("Spot", spottedPlayer)
        end
    end    
end

function SpottingComponent:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(SpottingComponent)
return SpottingComponent