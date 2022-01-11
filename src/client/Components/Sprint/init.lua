-- By Preston (seliso)
-- 1/10/2022
---------------------------------------------------------------------------------------------

local Modules = script.Parent.Parent.Parent:WaitForChild("Modules", 5)
local clientComm = require(Modules.ServerComm)
local enableSprint = clientComm:GetFunction("EnableSprint")
local disableSprint = clientComm:GetFunction("EnableSprint")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local Sprint = {}
Sprint.__index = Sprint

--local methods
---------------------------------------------------------------------------------

local function setSprint(self, action: boolean)
    if (self.Humanoid:GetAttribute("CanSprint") == false) then return end

    if (action == true) then
        enableSprint()
    else
        disableSprint()
    end
end

---------------------------------------------------------------------------------

function Sprint.new(humanoid : Humanoid)
    return setmetatable({
        Humanoid = humanoid :: Humanoid,
        Cleaner = Trove.new() :: typeof(Trove),
        Keyboard = Input.Keyboard.new() :: typeof(Input.Keyboard)
    }, Sprint)
end

function Sprint:Initial()

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

function Sprint:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Sprint", {Sprint})

return Sprint