local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local WeaponStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))

local rng = Random.new()

local RANGE = 5000

return function(weaponStats: typeof(WeaponStats), model: Model, barrel: BasePart)
	local target = (barrel.CFrame * CFrame.new(-5, 0, 0)).Position
    local origin = barrel.Position

    local spread = rng:NextNumber(weaponStats.MinSpread, weaponStats.MaxSpread)/500 or 0
	local distance = (origin - target).Magnitude :: number
	local num = spread * distance 
	local aim = Vector3.new(
		target.X + rng:NextNumber(-num, num),
		target.Y + rng:NextNumber(-num, num),
		target.Z + rng:NextNumber(-num, num)
	)
	
	local ray = Ray.new(origin, (aim - origin).Unit * RANGE)

	local ignoreList = CollectionService:GetTagged("Ignore")
	table.insert(ignoreList, model)
	if model.Parent:IsA("Model") then
		table.insert(ignoreList, model.Parent)
	end
	
	local part, position = workspace:FindPartOnRayWithIgnoreList(
		ray,
		ignoreList, 
		false, -- terrain cells are cubes
		true   -- ignore water
	)
	
	return part, position -- hit part, hit position
end