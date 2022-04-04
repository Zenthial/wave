local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local wcs = require(Shared.wcs)
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local Player = {}
Player.__index = Player
Player.Name = "ClientPlayer"
Player.Tag = "Player"
Player.Ancestor = Players
Player.Needs = {"Cleaner"}

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
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

wcs.create_component(Player)

return Player