local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local bluejay = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("bluejay"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Trove = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local MainHUD = PlayerGui:WaitForChild("MainHUD")
local MainMenu = MainHUD:WaitForChild("Menu")

local InputController = {}

function InputController:Start()
    local cleaner = Trove.new()
    local keyboardInput = Input.Keyboard.new()
    local mouseInput = Input.Mouse.new()

    local InventoryComponent = bluejay.get_component(LocalPlayer, "Inventory")
    local MenuStateComponent = bluejay.get_component(LocalPlayer, "MenuState")
    local MainMenuComponent = bluejay.get_component(MainMenu, "MainMenu")

    cleaner:Add(mouseInput.LeftDown:Connect(function()
        InventoryComponent:MouseDown()
    end))

    cleaner:Add(mouseInput.LeftUp:Connect(function()
        InventoryComponent:MouseUp()
    end))

    cleaner:Add(keyboardInput.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode.Slash then
            LocalPlayer:SetAttribute("Chatting", true)
        elseif keyCode == Enum.KeyCode.M then
            -- redo this, as inventory component shouldn't be accessing state variables of MainMenuComponent
            if MainMenuComponent.Open then
                MainMenuComponent:CloseMenu()
            else
                MainMenuComponent:OpenMenu()
            end
        elseif keyCode == Enum.KeyCode.B then
            MenuStateComponent:FeedInput()
        else
            InventoryComponent:FeedInput(keyCode)
        end
    end))
end

return InputController