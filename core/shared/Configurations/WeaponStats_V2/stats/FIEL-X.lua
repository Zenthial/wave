local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))

-- all of the below tables, except the caches, are just enums
local GunTypes = {
    Auto = "Auto",
    Semi = "Semi",
}

local FireMode = {
    Single = "Single",
    Shotgun = "Shotgun",
    Burst = "Burst",
}

local BulletType = {
    Ray = "Ray",
    Lighting = "Lighting",
    Projectile = "Projectile",
}

local AmmoType = {
    Battery = "Battery",
    Ammo = "Ammo"
}

local Bullets = {
    Default = BulletAssets:WaitForChild("Default")
}

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    CollectionService:AddTag(Bullets.Default, "Ignore")
    Caches.DefaultCache = PartCache.new(Bullets.Default, 200)
end

local Holsters = {
    Back = "Back",
    TorsoModule = "TorsoModule",
    Hip = "Hip",
    RightArmModule = "RightArmModule",
    LeftArmModule = "LeftArmModule",
    Melee = "Melee"
}

return {
	Name = "FIEL-X",
	FullName = "Shock Field Generator",
	Category = "Suit module",
	QuickDescription = "Area Damage",
	Description = "The Field Generator X is a special harness mounted to one of the arms, or other relevant appendages, of a trooper. Upon activation, the device effectively amplifies the wearer?s arm strength by a large factor by generating a phased energy field around it.",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.RightArmModule,
	Trigger = "Press",
	Damage = 60,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage * (10/distance), 0, 60)
	end,
	VehicleMultiplier = 2,
	EnergyDeplete = 100,
	EnergyRegen = 3,
	EnergyMin = 99,
}
