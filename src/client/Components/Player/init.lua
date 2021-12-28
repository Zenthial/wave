local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))

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
end

function Player:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Player", {Player})

return Player