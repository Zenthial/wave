--[=[
    Written by tom and Preston
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = script.Parent.Parent:WaitForChild("Modules", 5)

local clientComm = require(Modules.ClientComm)
local toggleSprint = clientComm.GetComm():GetFunction("ToggleSprint")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))
local Signal = require(Shared:WaitForChild("util", 5):WaitForChild("Signal", 5))

local camera = workspace.CurrentCamera

local function setSprint(self, action: boolean)
    if (self.Humanoid:GetAttribute("CanSprint") == false) then return end

    self.Events.SprintChanged:Fire(action)
    toggleSprint(action)
end

local function setCrouch(self, action: boolean)
    
end

local Movement = {}
Movement.__index = Movement
Movement.__Tag = "Movement"

function Movement.new(root: any)
    return setmetatable({
        Humanoid = root.Humanoid :: Humanoid,
        Cleaner = Trove.new() :: typeof(Trove),
        Keyboard = Input.Keyboard.new() :: typeof(Input.Keyboard),

        Events = {
            SprintChanged = Signal.new(),
            CrouchChanged = Signal.new(),
        }
    }, Movement)
end

function Movement:Initial()

    self.Cleaner:Add(self.Keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
        if (keyCode == Enum.KeyCode.LeftShift) then
            setSprint(self, true)
        end
    end))

    self.Cleaner:Add(self.Keyboard.KeyUp:Connect(function(keyCode: Enum.KeyCode)
        if (keyCode == Enum.KeyCode.LeftShift) then
            setSprint(self, false)
        end
    end))

end

function Movement:SetSprint(sprint: boolean)
    setSprint(self, sprint)
end

function Movement:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Movement", {Movement})

return Movement