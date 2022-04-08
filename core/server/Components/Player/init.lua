local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local bluejay = require(Shared:WaitForChild("bluejay", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local comm = require(script.Parent.Parent.Modules.ServerComm)
local ServerComm = comm.GetServerComm()

local playerLoadedSignal = ServerComm:CreateSignal("PlayerLoaded")

local Player = {}
Player.__index = Player
Player.Name = "ServerPlayer"
Player.Tag = "Player"
-- Player.Ancestor = Players
Player.Needs = {"Cleaner"}

function Player.new(player: Player)
    return setmetatable({
            Player = player,
    }, Player)
end

function Player:Start()
    self.Player:SetAttribute("Loaded", false)

    self.Cleaner:Add(playerLoadedSignal:Connect(function(player: Player)
        if self.Player == player then
            self.Player:SetAttribute("Loaded", true)
        end
    end))
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

bluejay.create_component(Player)

return Player