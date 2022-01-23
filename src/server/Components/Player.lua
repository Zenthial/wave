local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local comm = require(script.Parent.Parent.Modules.ServerComm)
local ServerComm = comm.GetServerComm()

local playerLoadedSignal = ServerComm:CreateSignal("PlayerLoaded")

local Player = {}
Player.__index = Player

function Player.new(player: Player)
    return setmetatable({
            Player = player,
            Cleaner = Trove.new() :: typeof(Trove),
    }, Player)
end

function Player:Initial()
    self.Player:SetAttribute("Loaded", false)

    self.Cleaner:Add(playerLoadedSignal:Connect(function(player: Player)
        print("yo")
        if self.Player == player then
            self.Player:SetAttribute("Loaded", true)
        end
    end))
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Player})

return Player