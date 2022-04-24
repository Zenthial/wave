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
	Name = "C25",
	FullName = "Plasma Grenade Launcher",
	Category = "Assault",
	Description = "It shoot's C0S's. Maybe.",
	QuickDescription = "Single Explosive Projectile",
	WeaponCost = 3000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	BatteryDepletionMin = 0,
	BatteryDepletionMax = 0,
	ShotsDeplete = 1,
	MaxSpread = 0,
	MinSpread = 0,
	HeatRate = 2,
	CoolTime = 2,
	CoolWait = 1,
	FireRate = 0,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Launcher,
	BulletType = BulletType.Projectile,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

	Damage = 1,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage + (20 * (1 / distance)), 1, 25)
	end,
	VehicleMultiplier = 10,
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.25, -.5) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
