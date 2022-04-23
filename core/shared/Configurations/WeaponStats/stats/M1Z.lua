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
	Name = "M1Z",
	FullName = "Proximity Mine",
	Category = "Deployable",
	Description = "The Mark 1 Zone Denial System is a quick deployment mechanism for a system of easily concealable, high impact land mines. Once placed the detonation mechanism of the mine arms, waiting for hostiles to get in just a bit too close before delivering a fatal explosive payload.",
	QuickDescription = "Area Damage",
	WeaponCost = 1000,
	Slot = 3,
	Locked = false,
	Type = "Deployable",
	CanTeamKill = false,
	DeployTime = 0.5,
	TeamKillPrevention = true,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
}
