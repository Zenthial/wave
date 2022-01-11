-- By Preston (seliso)
-- 1/11/2022
---------------------------------------------------------------------------------------------

local Modules = script.Parent.Parent:WaitForChild("Modules", 5)
local serverComm = require(Modules.ServerComm)

--Shared
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("Util", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local Sprint = {}
Sprint.__index = Sprint

---------------------------------------------------------------------------------------------

serverComm.GetComm():BindFunction("EnableSprint", function(player: Player) 
    local sprintComp = player.Character and Rosyn.GetComponentsFromInstance(player.Character)
    if (sprintComp == nil) then return end

    sprintComp:EnableSprint()
end)

serverComm.GetComm():BindFunction("Disableprint", function(player: Player) 
    local sprintComp = player.Character and Rosyn.GetComponentsFromInstance(player.Character)
    if (sprintComp == nil) then return end

    sprintComp:DisableSprint()
end)

---------------------------------------------------------------------------------------------

function Sprint.new(humanoid : Humanoid)
    return setmetatable({
        Humanoid = humanoid :: Humanoid,
        Cleaner = Trove.new() :: typeof(Trove),
    }, Sprint)
end

function Sprint:Initial()
    self.Humanoid:SetAttribute("Sprinting", false)
    self.Humanoid:SetAttribute("CanSprint", false)
end

function Sprint:EnableSprint()
    if (self.Humanoid:GetAttribute("CanSprint") == false) then return end

    self.Humanoid:SetAttribute("Sprinting", true)
    self.Humanoid.WalkSpeed = 22
end

function Sprint:DisableSprint()
    self.Humanoid:SetAttribute("Sprinting", false)
    self.Humanoid.WalkSpeed = 16
end

function Sprint:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Sprint", {Sprint}, workspace)

return Sprint;