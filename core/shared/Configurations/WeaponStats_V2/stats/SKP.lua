local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
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

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    local weapon = Weapons:FindFirstChild(script.Name)
    if weapon then
        local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile")
        if bullet then
            CollectionService:AddTag(bullet, "Ignore")
            Caches.DefaultCache = PartCache.new(bullet, 50)
        end
    end
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
	Name = "SKP",
	FullName = "Autophaser",
	Category = "SMG",
	Description = "Manufactured by GORIUS Armories, The SKPa (StarKnight Photon accelerator), named SKP for convenience is an autophaser with a high fire rate and respectable damage in a compact and stylish package. SKP makes up for what it lacks in accuracy with a devastating rate of fire.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 1500,
	AmmoType = AmmoType.Battery,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 0,
	EquipTime = 0.2,
	BatteryDepletionMin = 4,
	BatteryDepletionMax = 5,
	ShotsDeplete = 10,
	MaxSpread = 2,
	MinSpread = 0.5,
	HeatRate = 3,
	CoolTime = 3,
	CoolWait = 0.3,
	Damage = 4,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 14,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -1, -.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		}
	},
}
