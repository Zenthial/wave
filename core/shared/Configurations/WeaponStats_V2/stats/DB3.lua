local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
-- all of the below tables, except the caches, are just enums

local FireMode = {
    Single = "Single",
    Shotgun = "Shotgun",
    Burst = "Burst",
}

local BulletType = {
    Ray = "Ray",
    Streak = "Streak",
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
	Name = "DB3",
	FullName = "Dual-Barrel Mark 3",
	Category = "Explosive",
	Description = "The Dual Barrel Mark 3 is an experimental plasma cannon entering the final stages of R&D from HilTech. The weapon is named as such for its two sets of triple-barreled plasma cannons, which when charged up are capable of delivering a rapid burst of three plasma shots at a given target, resulting in heavy damage and suppressive capability.",
	QuickDescription = "Multi-Barrel Plasma Burst Cannon",
	WeaponCost = 3000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 6,
	CanSprint = false,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 3,
	EquipTime = 0.4,
	BatteryDepletionMin = 5,
	BatteryDepletionMax = 5,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 1,
	HeatRate = 25,
	CoolTime = 4,
	CoolWait = 0.2,
	Damage = 20,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 10,
	BlastRadius = 20,
	FireRate = 5,
	ChargeWait = 0.5,
	Trigger = "Semi",
	FireMode = FireMode.BurstExplosive,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -1, -0.5) * CFrame.Angles(math.rad(0),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
