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
	Name = "H3G",
	FullName = "Nanite Delivery Grenade",
	Category = "Grenade",
	Description = "The Helios Mk. 3 Grenade is a specialized grenade issued to WIJ medical operatives.  It has very simple and easy to use code keys which ensure proper usage of the ordnance. Upon being thrown the grenade releases its payload of healing nanites, which affix to any allied personnel in the area and effect healing immediately.",
	QuickDescription = "Radial Healing Effect",
	WeaponCost = 1500,
	Slot = 3,
	Type = "Projectile",
	CanTeamKill = false,
	Locked = false,
	Damage = -50,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 10,
}
