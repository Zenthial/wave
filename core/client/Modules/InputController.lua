local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
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

    -- local MenuStateComponent = tcs.get_component(LocalPlayer, "MenuState")
    -- local MainMenuComponent = tcs.get_component(MainMenu, "MainMenu")

    cleaner:Add(mouseInput.LeftDown:Connect(function()
        local InventoryComponent = tcs.get_component(LocalPlayer, "Inventory")
        InventoryComponent:MouseDown()
    end))

    cleaner:Add(mouseInput.LeftUp:Connect(function()
        local InventoryComponent = tcs.get_component(LocalPlayer, "Inventory")
        InventoryComponent:MouseUp()
    end))

    cleaner:Add(keyboardInput.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Chat")] then
            LocalPlayer:SetAttribute("Chatting", true)
        -- elseif keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Menu")] then
        --     -- redo this, as inventory component shouldn't be accessing state variables of MainMenuComponent
        --     if MainMenuComponent.Open then
        --         MainMenuComponent:CloseMenu()
        --     else
        --         MainMenuComponent:OpenMenu()
        --     end
        -- elseif keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Inventory")] then
        --     MenuStateComponent:FeedInput()
        elseif keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Spot")] then
            local SpottingComponent = tcs.get_component(LocalPlayer, "SpottingComponent")
            SpottingComponent:FeedInput()
        else
            local InventoryComponent = tcs.get_component(LocalPlayer, "Inventory")
            InventoryComponent:FeedKeyDown(keyCode)
        end
    end))

    cleaner:Add(keyboardInput.KeyUp:Connect(function(keyCode: Enum.KeyCode)
        local InventoryComponent = tcs.get_component(LocalPlayer, "Inventory")
        InventoryComponent:FeedKeyUp(keyCode)
    end))
end

return InputController
