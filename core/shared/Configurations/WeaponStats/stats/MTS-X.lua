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
	Name = "MTS-X",
	FullName = "Anti-Vehicle	Deployable Turret",
	Category = "Deployable",
	Description = "The MTS-X is a ready-made engineering package which is capable of deploying a vehicle-grade turret at the position of unpacking. Unlike the standard engineering issue MTA-S, the MTS-X fabricates a turret utilizing AT phase coils allowing it to deliver a less sustained but more directly powerful explosive attack.",
	QuickDescription = "Semi Automatic, Single Explosive Shot",
	WeaponCost = 3000,
	Slot = 3,
	DeltaSlot = 5,
	Type = "Deployable",
	NumBarrels = 3,
	CanSprint = false,
	CanCrouch = false,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 0,
	EquipTime = 0,
	DeployTime = 1,
	TeamKillPrevention = false,
	MaxSpread = 1,
	MinSpread = 0.5,
	HeatRate = 15,
	CoolTime = 6,
	CoolWait = 0.5,
	VehicleMultiplier = 10,
	CalculateDamage = function(damage, distance)
		return damage + (40 * (1/distance))
	end,
	FireRate = 10,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.SingleExplosive,
	BulletType = BulletType.Ray,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

}
