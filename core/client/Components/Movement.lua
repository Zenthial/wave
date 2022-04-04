local ReplicatedStorage = game:GetService("ReplicatedStorage")

local wcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("wcs"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Keyboard = Input.Keyboard

local Movement = {}
Movement.__index = Movement
Movement.Name = "Movement"
Movement.Tag = "Movement"
Movement.Ancestor = game
Movement.Needs = {"Cleaner"}

function Movement.new(root: any)
    return setmetatable({
        Root = root,
    }, Movement)
end

function Movement:CreateDependencies()
    return {}
end

function Movement:Start()
	local keyboard = Keyboard.new()
	local char = self.Root.Character or self.Root.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")

	self.Root:SetAttribute("LocalSprinting", false)
	self.Root:SetAttribute("LocalCrouching", false)
	self.Root:SetAttribute("LocalRolling", false)
	self.Character = char
	self.Humanoid = hum

	self.Cleaner:Add(keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
		if keyCode == Enum.KeyCode.LeftShift then
			self.Root:SetAttribute("LocalSprinting", true)
			self:UpdateWalkspeed()
		elseif keyCode == Enum.KeyCode.C then
			self.Root:SetAttribute("LocalCrouching", not self.Root:GetAttribute("LocalCrouching"))
			self:UpdateWalkspeed()
		end
	end))

	self.Cleaner:Add(keyboard.KeyUp:Connect(function(keyCode: Enum.KeyCode)
		if keyCode == Enum.KeyCode.LeftShift then
			self.Root:SetAttribute("LocalSprinting", false)
			self:UpdateWalkspeed()	
		end
	end))
end

function Movement:UpdateWalkspeed()
	self.Humanoid.WalkSpeed = 16
		
	if self.Root:GetAttribute("Aiming") == true then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 4
	end
	
	if self.Root:GetAttribute("LocalCrouching") == true then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed - 8
	end
	
	if self.Root:GetAttribute("LocalSprinting") == true or self.Root:GetAttribute("LocalRolling") == true then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 10
	end
	
	if self.Root:GetAttribute("NumWeaponsEquipped") > 0 then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed -- subtract walkspeed reduce of equipped weapon
	end
	
	if not self.Root:GetAttribute("HasPrimaryWeapon") == true then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed + 5
	end


    -- if not self.Root:GetAttribute("PlayerAvailable") == true or self.Root:GetAttribute("PlacingDeployable") == true or self.Root:GetAttribute("Restrained") == true then
	-- 	self.Humanoid.WalkSpeed = 0
	-- end
end

function Movement:Destroy()
    self.Cleaner:Clean()
end

wcs.create_component(Movement)

return Movement