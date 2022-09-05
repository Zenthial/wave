local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Head = Character.Head or Character:WaitForChild("Head") :: Part
local Mouse = Player:GetMouse()
local rng = Random.new()

local RANGE = 1000

return function(weaponStats: typeof(WeaponStats))
	local target = Mouse.Hit.Position
    local origin = Head.Position

    local spread = rng:NextNumber(weaponStats.MinSpread, weaponStats.MaxSpread)/100 or 0
	local distance = (origin - target).magnitude
	local num = spread*distance 
	local aim = Vector3.new(
		target.X + rng:NextNumber(-num, num),
		target.Y + rng:NextNumber(-num, num),
		target.Z + rng:NextNumber(-num, num)
	)
	
	local ray = Ray.new(origin, (aim - origin).unit * RANGE)
	local part, position = workspace:FindPartOnRayWithIgnoreList(
		ray, 
		CollectionService:GetTagged("Ignore"), 
		false, -- terrain cells are cubes
		true   -- ignore water
	)
	
	return part, position -- hit part, hit position
end