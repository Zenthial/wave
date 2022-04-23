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
	Name = "C0S",
	FullName = "Distortion Grenade",
	Category = "Grenade",
	Description = "The Caustic Obliteration Sphere Grenade is a specialized area-denial munition. Once thrown and activated the grenade quickly disperses large amounts of heat and plasma within a contained area. Personnel caught in the area of effect are quickly chewed through, taking damage until they are able to escape the field or are dissolved by the plasma.",
	QuickDescription = "Temporary Constant Area Damage",
	WeaponCost = 1500,
	Slot = 3,
	Type = "Projectile",
	CanTeamKill = false,
	Locked = false,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage + (10 * (1 / distance)), 1, 15)
	end,
	VehicleMultiplier = 0.2,
}
