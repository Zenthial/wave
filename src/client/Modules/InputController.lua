local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Rosyn = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Inventory = require(StarterPlayerScripts.Client.Components.Inventory)

local LocalPlayer = Players.LocalPlayer

local InputController = {}

function InputController:Start()
    local cleaner = Trove.new()
    local keyboardInput = Input.Keyboard.new()
    local mouseInput = Input.Mouse.new()

    LocalPlayer:SetAttribute("Chatting", false)

    local InventoryComponent = Rosyn.AwaitComponentInit(LocalPlayer, Inventory) :: typeof(Inventory)

    cleaner:Add(mouseInput.LeftDown:Connect(function()
        InventoryComponent:MouseDown()
    end))

    cleaner:Add(mouseInput.LeftUp:Connect(function()
        InventoryComponent:MouseUp()
    end))

    cleaner:Add(keyboardInput.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode.Slash then
            LocalPlayer:SetAttribute("Chatting", true)
        else
            InventoryComponent:FeedInput(keyCode)
        end
    end))
end

return InputController