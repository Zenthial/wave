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
	Name = "AAQ",
	FullName = "Automated Targeting Deployable Turret",
	Category = "Deployable",
	QuickDescription = "Automatic, Single Shot",
	Description = "The Aggressive Automated Quick reactor is a sophisticated light-armoured turret defense system. Outfitted with a proximity sensor, the AAQ is designed to neutralize or suppress any hostile entities that wander within range of its rapid-fire phaser coil.",
	WeaponCost = 5000,
	Slot = 3,
	Type = "Deployable",
	CanTeamKill = false,
	Locked = true,
	DeployTime = 1.5,
	TeamKillPrevention = true,
	MaxSpread = 7,
	MinSpread = 5,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
	FireRate = 10,
	ChargeWait = 0,
	BulletType = BulletType.Ray,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

}
