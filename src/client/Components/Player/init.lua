local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local Mouse = require(script.Mouse)

local createFrame = require(script.Parent.Parent.Helper.createFrame)

local Player = {}
Player.__index = Player

function Player.new(player: Player)
    return setmetatable({
            Player = player,
            Cleaner = Trove.new() :: typeof(Trove),
            Keyboard = Input.Keyboard.new() :: typeof(Input.Keyboard),
            Mouse = Input.Mouse.new() :: typeof(Input.Mouse),
    }, Player)
end

function Player:Initial()
    -- titan animation trigger
    self.Cleaner:Add(self.Keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode.E then
            createFrame(self.Player.Character.HumanoidRootPart.CFrame)
        end
    end))

    local MouseComponent = Rosyn.AwaitComponentInit(self.Player, Mouse)

    local player = self.Player :: Player
    player.CameraMaxZoomDistance = 25
    player.CameraMinZoomDistance = 5
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Player})

return Player