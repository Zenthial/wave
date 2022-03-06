--[=[
    By tom and preston
]=]
local Players = game:GetService("Players")
local Modules = script.Parent.Parent.Parent:WaitForChild("Modules", 5)
local serverComm = require(Modules.ServerComm)

--Shared
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared", 5)
local Util = Shared:WaitForChild("Util", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local Movement = {}
Movement.__index = Movement
Movement.__Tag = "Movement"

serverComm.GetComm():BindFunction("ToggleSprint", function(player: Player, action: boolean) 
    local MovementComp = player.Character and Rosyn.GetComponent(player.Character, Movement)
    if (MovementComp == nil) then return end

    if action then
        MovementComp:EnableSprint()
    else
        MovementComp:DisableSprint()
    end
end)

serverComm.GetComm():BindFunction("ToggleCrouch", function(player: Player, action: boolean) 
    local MovementComp = player.Character and Rosyn.GetComponent(player.Character, Movement)
    if (MovementComp == nil) then return end

    if action then
        MovementComp:EnableCrouch()
    else
        MovementComp:DisableCrouch()
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
    self.Player = Players:GetPlayerFromCharacter(self.Character)
    self.Character:SetAttribute("Sprinting", false)
    self.Character:SetAttribute("CanSprint", true)

    self.Character:SetAttribute("Crouching", false)
    self.Character:SetAttribute("CanCrouch", true)

    self:UpdateWalkspeed()
end

function Movement:EnableSprint()
    if (self.Character:GetAttribute("CanSprint") == false) then return end
    self.Character:SetAttribute("Sprinting", true)
    self:UpdateWalkspeed()
end

function Movement:DisableSprint()
    self.Character:SetAttribute("Sprinting", false)
    self:UpdateWalkspeed()
end

function Movement:EnableCrouch()
    if (self.Character:GetAttribute("CanCrouch") == false) then return end
    self.Character:SetAttribute("Crouching", true)
    self:UpdateWalkspeed()
end

function Movement:DisableCrouch()
    self.Character:SetAttribute("Crouching", false)
    self:UpdateWalkspeed()
end

function Movement:UpdateWalkspeed()
    -- if not self.Character:GetAttribute("CharacterAvailable") == true or self.Character:GetAttribute("PlacingDeployable") == true or self.Character:GetAttribute("Restrained") == true then
	-- 	self.Humanoid.WalkSpeed = 0
	-- else
		self.Humanoid.WalkSpeed = 16
		
		if self.Character:GetAttribute("Aiming") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 4
		end
		
		if self.Character:GetAttribute("Crouching") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 8
		end
		
		if self.Character:GetAttribute("Sprinting") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 10
		end
		
		if self.Player:GetAttribute("NumWeaponsEquipped") > 0 then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed -- subtract walkspeed reduce of equipped weapon
		end
		
		if not self.Player:GetAttribute("HasPrimaryWeapon") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 5
		end
	-- end
end

function Movement:Destroy()
    self.Cleaner:Destroy()
end

Rosyn.Register("Movement", {Movement}, workspace)

return Movement;