local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local Player = {}
Player.__index = Player

function Player.new(player: Player)
    return setmetatable({
            Player = player,
            Cleaner = Trove.new() :: typeof(Trove),
    }, Player)
end

function Player:Initial()
    
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Player})

return Player