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
	Name = "D01",
	FullName = "Orbital Target Designator-01",
	Category = "Assault",
	Description = "The ability for a squad commander to call in orbital fire support is invaluable. Once a target has been designated by the D01, a command is relayed to a appropriately equipped warship or satellite in orbit to fire its phaser array to a devastating effect, within seconds.",
	QuickDescription = "Single Shot",
	WeaponCost = 94000,
	AmmoType = AmmoType.Battery,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 0,
	EquipTime = 0.1,
	BatteryDepletionMin = 100,
	BatteryDepletionMax = 100,
	ShotsDeplete = 1,
	MaxSpread = 2.5,
	MinSpread = 0.5,
	HeatRate = 100,
	CoolTime = 3,
	CoolWait = 0,
	Damage = 100,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 100,
	FireRate = 0,
	ChargeWait = 4,
	Trigger = "Semi",
	FireMode = FireMode.OrbitalStrike,
	BulletType = BulletType.OrbitalRay,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90), 0 ,0),
			C1 = CFrame.new()
		},
	},
}
