local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local tcs = require(Shared.tcs)
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))
local Courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local followPlayer = require(script.Parent.Parent.Modules.CameraFunctions.followPlayer)

local Player = {}
Player.__index = Player
Player.Name = "ClientPlayer"
Player.Tag = "Player"
Player.Ancestor = Players

function Player.new(player: Player)
    return setmetatable({
            Player = player,
            Keyboard = Input.Keyboard.new() :: typeof(Input.Keyboard),
            Mouse = Input.Mouse.new() :: typeof(Input.Mouse),
    }, Player)
end

function Player:Start()
    -- titan animation trigger
    -- self.Cleaner:Add(self.Keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
    --     if keyCode == Enum.KeyCode.E then
    --         createFrame(self.Player.Character.HumanoidRootPart.CFrame)
    --     end
    -- end))

    local player = self.Player :: Player
    player.CameraMaxZoomDistance = 25
    player.CameraMinZoomDistance = 5

    local character = player.Character or player.CharacterAdded:Wait()

    for _, thing in pairs(character:GetDescendants()) do
        if CollectionService:HasTag(thing, "Ignore") then
            CollectionService:AddTag(thing, "Ignore")
        end
    end

    self.Cleaner:Add(character.DescendantAdded:Connect(function(descendant)
        CollectionService:AddTag(descendant, "Ignore")
    end))

    self.Cleaner:Add(Courier:Listen("CameraFollow"):Connect(function(optionalPosition)
        local killer = player:GetAttribute("LastKiller")
        print(killer)
        if killer ~= "" then
            local playerToFollow = Players:FindFirstChild(killer)
            followPlayer(playerToFollow)
        else
            followPlayer(optionalPosition)
        end
    end))
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

tcs.create_component(Player)

return Player