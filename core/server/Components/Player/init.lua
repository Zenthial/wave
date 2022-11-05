local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local InventoryStats = require(Shared:WaitForChild("Configurations"):WaitForChild("InventoryStats"))

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
Player.Ancestor = Players

function Player.new(player: Player)
    return setmetatable({
            Player = player,
    }, Player)
end

function Player:Start()
    self.Player:SetAttribute("Loaded", false)
    CollectionService:AddTag(self.Player, "HealthTag")

    local playerFolder = Instance.new("Folder")
    playerFolder.Name = self.Player.Name
    playerFolder.Parent = PlayerFolders

    task.spawn(function()
        local character = self.Player.Character or self.Player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid") :: Humanoid
        humanoid.NameDisplayDistance = 0

        for _, thing in character:GetDescendants() do
            if thing:IsA("Accessory") then
                CollectionService:AddTag(thing, "Ignore")
            end
        end
    end)

    self.Cleaner:Add(playerLoadedSignal.OnServerEvent:Connect(function(player: Player)
        if self.Player == player then
            self.Player:SetAttribute("Loaded", true)
        end
    end))

    self.Cleaner:Add(playerFolder)

    local serverInventoryComponent = tcs.get_component(self.Player, "ServerInventory")
    serverInventoryComponent:LoadServerInventory(InventoryStats)
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Player)

return Player
