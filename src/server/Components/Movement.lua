--[=[
    By tom and preston
]=]
local Modules = script.Parent.Parent:WaitForChild("Modules", 5)
local serverComm = require(Modules.ServerComm)

--Shared
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("Util", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local Movement = {}
Movement.__index = Movement

serverComm.GetComm():BindFunction("ToggleSprint", function(player: Player, action: boolean) 
    local MovementComp = player.Character and Rosyn.GetComponent(player.Character, Movement)
    if (MovementComp == nil) then return end

    if action then
        MovementComp:EnableSprint()
    else
        MovementComp:DisableSprint()
    end
end)

function Movement.new(root: Model)
    return setmetatable({
        Character = root,
        Humanoid = root.Humanoid :: Humanoid,
        
        Cleaner = Trove.new() :: typeof(Trove),
    }, Movement)
end

function Movement:Initial()
    self.Humanoid:SetAttribute("Sprinting", false)
    self.Humanoid:SetAttribute("CanSprint", true)

    self.Humanoid:SetAttribute("Crouching", false)
    self.Humanoid:SetAttribute("CanCrouch", true)
end

function Movement:EnableSprint()
    if (self.Humanoid:GetAttribute("CanSprint") == false) then return end
    self.Humanoid:SetAttribute("Sprinting", true)
    self.Humanoid.WalkSpeed = 25
end

function Movement:DisableSprint()
    self.Humanoid:SetAttribute("Sprinting", false)
    self.Humanoid.WalkSpeed = 16
end

function Movement:UpdateWalkspeed()
    if not self.Character:GetAttribute("CharacterAvailable") or self.Character:GetAttribute("PlacingDeployable") or self.Character:GetAttribute("Restrainted") then
		self.Humanoid.WalkSpeed = 0
	else
		self.Humanoid.WalkSpeed = 16
		
		if self.Character:GetAttribute("Aiming") then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 4
		end
		
		if self.Character:GetAttribute("Crouching") then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 8
		end
		
		if self.Character:GetAttribute("Sprinting") then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 10
		end
		
		if self.Character:GetAttribute("NumWeaponsEquipped") > 0 then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - self.Character:GetAttribute("weaponstats").walkspeedreduce
		end
		
		if not self.Character:GetAttribute("HasPrimaryWeapon") then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 5
		end
	end
end

function Movement:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Movement", {Movement}, workspace)

return Movement;