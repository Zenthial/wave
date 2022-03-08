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
    local MovementComp = player and Rosyn.GetComponent(player, Movement)
    if (MovementComp == nil) then return end

    if action then
        MovementComp:EnableSprint()
    else
        MovementComp:DisableSprint()
    end
end)

serverComm.GetComm():BindFunction("ToggleCrouch", function(player: Player, action: boolean) 
    local MovementComp = player and Rosyn.GetComponent(player, Movement)
    if (MovementComp == nil) then return end

    if action then
        MovementComp:EnableCrouch()
    else
        MovementComp:DisableCrouch()
    end
end)

function Movement.new(root: Model)
    return setmetatable({
        Player = root,
        Humanoid = root.Humanoid :: Humanoid,
        
        Cleaner = Trove.new() :: typeof(Trove),
    }, Movement)
end

function Movement:Initial()
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")

    self.Cleaner:Add(self.Player.CharacterAdded:Connect(function()
        self.Character = self.Player.Character
        self.Humanoid = self.Character:WaitForChild("Humanoid")
    end))

    self.Player:SetAttribute("Sprinting", false)
    self.Player:SetAttribute("CanSprint", true)

    self.Player:SetAttribute("Crouching", false)
    self.Player:SetAttribute("CanCrouch", true)

    self:UpdateWalkspeed()
end

function Movement:EnableSprint()
    if (self.Player:GetAttribute("CanSprint") == false) then return end
    self.Player:SetAttribute("Sprinting", true)
    self:UpdateWalkspeed()
end

function Movement:DisableSprint()
    self.Player:SetAttribute("Sprinting", false)
    self:UpdateWalkspeed()
end

function Movement:EnableCrouch()
    if (self.Player:GetAttribute("CanCrouch") == false) then return end
    self.Player:SetAttribute("Crouching", true)
    self:UpdateWalkspeed()
end

function Movement:DisableCrouch()
    self.Player:SetAttribute("Crouching", false)
    self:UpdateWalkspeed()
end

function Movement:UpdateWalkspeed()
    -- if not self.Player:GetAttribute("PlayerAvailable") == true or self.Player:GetAttribute("PlacingDeployable") == true or self.Player:GetAttribute("Restrained") == true then
	-- 	self.Humanoid.WalkSpeed = 0
	-- else
		self.Humanoid.WalkSpeed = 16
		
		if self.Player:GetAttribute("Aiming") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 4
		end
		
		if self.Player:GetAttribute("Crouching") == true then
			self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 8
		end
		
		if self.Player:GetAttribute("Sprinting") == true then
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

Rosyn.Register("Player", {Movement}, workspace)

return Movement;