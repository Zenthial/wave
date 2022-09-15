--[=[
    By tom and preston
]=]
local Players = game:GetService("Players")

--Shared
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local Movement = {}
Movement.__index = Movement
Movement.Name = "Movement"
Movement.Tag = "Movement"
Movement.Ancestor = Players
Movement.Needs = {"Cleaner"}

function Movement.new(root: Model)
    return setmetatable({
        Player = root,
    }, Movement)
end

function Movement:Start()
    self.Character = self.Player.Character or self.Player.CharacterAdded:Wait()
    self.Humanoid = self.Character:WaitForChild("Humanoid")

    self.Cleaner:Add(self.Player.CharacterAdded:Connect(function()
        self.Character = self.Player.Character
        self.Humanoid = self.Character:WaitForChild("Humanoid")
    end))

    self.Cleaner:Add(self.Player:GetAttributeChangedSignal("Sprinting"):Connect(function()
        if self.Player:GetAttribute("Sprinting") then
            self:EnableSprint()
        else
            self:DisableSprint()
        end
    end))

    self.Cleaner:Add(self.Player:GetAttributeChangedSignal("Crouching"):Connect(function()
        if self.Player:GetAttribute("Crouching") then
            self:EnableCrouch()
        else
            self:DisableCrouch()
        end
    end))

    self:UpdateWalkspeed()
end

function Movement:EnableSprint()
    if self.Player:GetAttribute("CanSprint") == false then return end
    self.Player:SetAttribute("Sprinting", true)
    self.Player:SetAttribute("Crouching", false)
    self:UpdateWalkspeed()
end

function Movement:DisableSprint()
    self.Player:SetAttribute("Sprinting", false)
    self:UpdateWalkspeed()
end

function Movement:EnableCrouch()
    if self.Player:GetAttribute("CanCrouch") == false then return end
    if self.Player:GetAttribute("Sprinting") == true and self.Player:GetAttribute("CanRoll") == true then
        self.Player:SetAttribute("Rolling", true)
        self.Player:SetAttribute("Sprinting", false)
        self.Player:SetAttribute("Crouching", false)
    else
        self.Player:SetAttribute("Crouching", true)
    end
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
		
		if self.Player:GetAttribute("Sprinting") == true or self.Player:GetAttribute("Rolling") == true then
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

tcs.create_component(Movement)

return Movement;