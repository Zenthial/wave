local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local tcs = require(Shared:WaitForChild("tcs", 5))

local PlayerFolders = Instance.new("Folder")
PlayerFolders.Name = "PlayerFolders"
PlayerFolders.Parent = ReplicatedStorage

local playerLoadedSignal = Instance.new("RemoteEvent")
playerLoadedSignal.Name = "PlayerLoaded"
playerLoadedSignal.Parent = ReplicatedStorage.Shared

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

    local playerFolder = Instance.new("Folder")
    playerFolder.Name = self.Player.Name
    playerFolder.Parent = PlayerFolders

    self.Cleaner:Add(playerLoadedSignal.OnServerEvent:Connect(function(player: Player)
        if self.Player == player then
            self.Player:SetAttribute("Loaded", true)
        end
    end))

    self.Cleaner:Add(playerFolder)
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Player)

return Player
