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
	Name = "MSI",
	FullName = "Magnetic Induction Rifle",
	Category = "Marksman",
	Description = "The Magnetic Surge Inductor rifle is the man-mobile form of an especially frightening weapons platform cooked up by an elite conference of WIJ?s top scientists. The weapon uses a system of subatomic levers to channel a power pack?s energy into a near impossibly high amperage and voltage electron bolt which arcs across from the rifle into any unsuspecting victim.",
	QuickDescription = "Single Charged Shot",
	WeaponCost = 6000,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	BatteryDepletionMin = 10,
	BatteryDepletionMax = 10,
	ShotsDeplete = 1,
	MaxSpread = 0,
	MinSpread = 0,
	HeatRate = 100,
	CoolTime = 4,
	CoolWait = 1,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 2,
	FireRate = 3,
	ChargeWait = 0.15,
	Trigger = "Semi",
	FireMode = FireMode.Single,
	BulletType = BulletType.Streak,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(-0.1, -.75, -0.45) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
