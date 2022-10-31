local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Input = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local GlobalOptions = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GlobalOptions"))
local Keyboard = Input.Keyboard

local LocalPlayer = Players.LocalPlayer

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

function Movement:Start()
	local keyboard = Keyboard.new()
	local char = self.Root.Character or self.Root.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid") :: Humanoid

	self.Root:SetAttribute("LocalSprinting", false)
	self.Root:SetAttribute("LocalCrouching", false)
	self.Root:SetAttribute("LocalRolling", false)
	self.Character = char
	self.Humanoid = hum

	self.Cleaner:Add(hum.Changed:Connect(function(prop)
		if prop == "MoveDirection" then
			if hum.MoveDirection.Magnitude == 0 then
				self.Root:SetAttribute("LocalSprinting", false)
			elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				self.Root:SetAttribute("LocalSprinting", true)
			end
		end
	end))

	self.Cleaner:Add(keyboard.KeyDown:Connect(function(keyCode: Enum.KeyCode)
		if keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Sprint")] then
			if self.Root:GetAttribute("LocalCanSprint") == false then return end
			if self.Root:GetAttribute("Firing") == true then return end
			if hum.MoveDirection == Vector3.new(0, 0, 0) then return end

			self.Root:SetAttribute("LocalSprinting", true)
		elseif keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Crouch")] then
			if self.Root:GetAttribute("LocalCanCrouch") == false then return end

			if not self.Root:GetAttribute("LocalRolling") then
				local currentTime = os.time()
				local timeBetweenRolls = currentTime - self.Root:GetAttribute("RollDebounce")  :: number
				if self.Root:GetAttribute("LocalSprinting") and timeBetweenRolls >= GlobalOptions.RollDebounce then
					self.Root:SetAttribute("LocalRolling", true)
					task.wait(0.55) -- from wace don't ask me
					self.Root:SetAttribute("LocalRolling", false)
					-- self.Root:SetAttribute("LocalCrouching", true)

					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						self.Root:SetAttribute("LocalSprinting", true)
					else
						self.Root:SetAttribute("LocalSprinting", false)
					end
					self:UpdateWalkspeed()
				else
					self.Root:SetAttribute("LocalCrouching", not self.Root:GetAttribute("LocalCrouching"))
				end
			end
		end
	end))

	self.Cleaner:Add(keyboard.KeyUp:Connect(function(keyCode: Enum.KeyCode)
		if keyCode == Enum.KeyCode[LocalPlayer.Keybinds:GetAttribute("Sprint")] then
			self.Root:SetAttribute("LocalSprinting", false)
		end
	end))

	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("LocalSprinting"):Connect(function() self:UpdateWalkspeed() end))
	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("LocalCrouching"):Connect(function() self:UpdateWalkspeed() end))
	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("LocalCanMove"):Connect(function() self:UpdateWalkspeed() end)) -- Potential to implement updatejumppower
	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("FielxActive"):Connect(function() self:UpdateWalkspeed() end))
	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("PlacingDeployable"):Connect(function() 
		self:UpdateWalkspeed() 
		self:UpdateJumpHeight()
	end))
	
	-- this is a fucking mess, but i think its a smart mess
	-- i may not need any of this since I'm also using LocalCanMove
	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("LocalCanSprint"):Connect(function()
		if self.Root:GetAttribute("LocalCanSprint") == false then
			self.Root:SetAttribute("LocalSprinting", false)
		end
	end))

	self.Cleaner:Add(self.Root:GetAttributeChangedSignal("LocalCanCrouch"):Connect(function()
		if self.Root:GetAttribute("LocalCanCrouch") == false then
			self.Root:SetAttribute("LocalCrouching", false)
		end
	end))
end

function Movement:UpdateWalkspeed()
	self.Humanoid.WalkSpeed = 16

	if self.Root:GetAttribute("LocalCanMove") == false then -- Why the hell is this not used for placing deployables?
		self.Humanoid.WalkSpeed = 0

		return
	end
		
	if self.Root:GetAttribute("Aiming") == true then
		self.Humanoid.WalkSpeed -= 4
	end
	
	if self.Root:GetAttribute("LocalCrouching") == true then
		self.Humanoid.WalkSpeed -= 8
	end
	
	if (self.Root:GetAttribute("LocalSprinting") == true and self.Root:GetAttribute("LocalCanSprint")) or self.Root:GetAttribute("LocalRolling") == true then
		self.Humanoid.WalkSpeed += 10
	end
	
	if self.Root:GetAttribute("NumWeaponsEquipped") > 0 then
		self.Humanoid.WalkSpeed = self.Humanoid.WalkSpeed -- subtract walkspeed reduce of equipped weapon
	end
	
	if not self.Root:GetAttribute("HasPrimaryWeapon") == true then
		self.Humanoid.WalkSpeed += 5
	end

	if self.Root:GetAttribute("FielxActive") == true then
		self.Humanoid.WalkSpeed -= 10
	end

	if self.Root:GetAttribute("PlacingDeployable") == true then
		self.Humanoid.WalkSpeed = 0
	end

    -- if not self.Root:GetAttribute("PlayerAvailable") == true or self.Root:GetAttribute("PlacingDeployable") == true or self.Root:GetAttribute("Restrained") == true then
	-- 	self.Humanoid.WalkSpeed = 0
	-- end
end

function Movement:UpdateJumpHeight()
	self.Humanoid.JumpHeight = 7.2

	-- Worth implementing CAnMove here?
	if self.Root:GetAttribute("PlacingDeployable") == true then
		self.Humanoid.JumpHeight = 0 
	end
end

function Movement:Destroy()
    self.Cleaner:Clean()
end

tcs.create_component(Movement)

return Movement