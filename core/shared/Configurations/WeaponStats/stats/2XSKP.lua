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
	Name = "2XSKP",
	FullName = "Dual Wielded Autophasers",
	Category = "SMG",
	Description = "Manufactured by GORIUS Armories, The SKPa (StarKnight Photon accelerator), named SKP for convenience is an autophaser with a high fire rate and respectable damage in a compact and stylish package. SKP makes up for what it lacks in accuracy with a devastating rate of fire.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 2500,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 2,
	NumBarrels = 2,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 2,
	EquipTime = 0.1,
	BatteryDepletionMin = 3,
	BatteryDepletionMax = 4,
	ShotsDeplete = 20,
	MaxSpread = 3,
	MinSpread = 1,
	HeatRate = 1.5,
	CoolTime = 5,
	CoolWait = 0.5,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 16,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletModel = Bullets.Default,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.5, -.25) * CFrame.Angles(math.rad(-180),math.rad(-180),0),
			C1 = CFrame.new()
		},
		{	limb = "Left Arm",
			C0 = CFrame.new(0, -.5, -.25) * CFrame.Angles(math.rad(-180),math.rad(-180),0),
			C1 = CFrame.new()
		}
	},
}
