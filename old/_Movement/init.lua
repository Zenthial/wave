--[=[
    Written by tom and Preston
]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent.Parent:WaitForChild("Modules", 5)

local clientComm = require(Modules.ClientComm)
local toggleSprint = clientComm.GetComm():GetFunction("ToggleSprint")
local toggleCrouch = clientComm.GetComm():GetFunction("ToggleCrouch")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local bluejay = require(Shared.bluejay)
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local Movement = {}
Movement.__index = Movement
Movement.Name = "Movement"
Movement.Tag = "Player"
Movement.Ancestor = Players
Movement.Needs = {"Cleaner"}

function Movement.new(root: any)
    return setmetatable({
        Player = root;
        Keyboard = Input.Keyboard.new() :: typeof(Input.Keyboard),

        State = {
            Crouching = false,
            Sprinting = false,
            Rolling = false,
        },
    }, Movement)
end

function Movement:Start()
    local character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Humanoid = character:WaitForChild("Humanoid") :: Humanoid

    self.Cleaner:Add(self.Keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if (keyCode == Enum.KeyCode.LeftShift) then
            self:SetSprint(true)
        elseif (keyCode == Enum.KeyCode.C) then
            self:SetCrouch(not self.State.Crouching)
        end
    end))

    self.Cleaner:Add(self.Keyboard.KeyUp:Connect(function(keyCode: Enum.KeyCode)
        if (keyCode == Enum.KeyCode.LeftShift) then
            self:SetSprint(false)
        end
    end))

    local LocalSprintingChangedSignal = self.Player:GetAttributeChangedSignal("LocalSprinting")
    local LocalCrouchingChangedSignal = self.Player:GetAttributeChangedSignal("LocalCrouching")
    local LocalRollingChangedSignal = self.Player:GetAttributeChangedSignal("LocalRolling")

    local SprintChangedSignal = self.Player:GetAttributeChangedSignal("Sprint")
    local CrouchChangedSignal = self.Player:GetAttributeChangedSignal("Crouch")
    local RollingChangedSignal = self.Player:GetAttributeChangedSignal("Rolling")

    self.Cleaner:Add(LocalSprintingChangedSignal:Connect(function()
        local attributeSprinting = self.Player:GetAttribute("LocalSprinting")
        if attributeSprinting ~= self.State.Sprinting then
            self:SetSprint(attributeSprinting)
        end
    end))

    self.Cleaner:Add(LocalCrouchingChangedSignal:Connect(function()
        local attributeCrouching = self.Player:GetAttribute("LocalCrouching")
        if attributeCrouching ~= self.State.Crouching then
            self:SetCrouch(attributeCrouching)
        end
    end))

    -- self.Cleaner:Add(LocalRollingChangedSignal:Connect(function()
    --     self:SetRolling(self.Player:GetAttribute("LocalRolling"))
    -- end))

    self.Cleaner:Add(SprintChangedSignal:Connect(function()
        self.Player:SetAttribute("LocalSprinting", self.Player:GetAttribute("Sprinting"))
    end))

    self.Cleaner:Add(CrouchChangedSignal:Connect(function()
        self.Player:SetAttribute("LocalCrouching", self.Player:GetAttribute("Crouching"))
    end))

    self.Cleaner:Add(RollingChangedSignal:Connect(function()
        self.Player:SetAttribute("LocalRolling", self.Player:GetAttribute("Rolling"))
    end))
end

function Movement:SetSprint(action: boolean)
    print(self.Player:GetAttribute("CanSprint"))
    if (self.Player:GetAttribute("CanSprint") == false) then return end

    self.Player:SetAttribute("LocalSprinting", action)
    if self.Player:GetAttribute("LocalCrouching") == true then
        self.Player:SetAttribute("LocalCrouching", false)
    end
    self.State.Sprinting = action
    toggleSprint(action)
end

function Movement:SetCrouch(action: boolean)
    if (self.Player:GetAttribute("CanCrouch") == false) then return end
    if (self.Player:GetAttribute("LocalRolling") == true) then return end

    if action and self.Player:GetAttribute("LocalSprinting") == true and self.Player:GetAttribute("CanRoll") == true then
        self.Player:SetAttribute("LocalRolling")
        self.State.Rolling = action
        toggleCrouch(action)
    else
        self.Player:SetAttribute("LocalCrouching", action)
        self.State.Crouching = action
        toggleCrouch(action)
    end
end

function Movement:Destroy()
    self.Cleaner:Destroy()
end

print("creating movement")
bluejay.create_component(Movement)

return Movement