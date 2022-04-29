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
	Name = "S13",
	FullName = "Marksman Rifle",
	Category = "Marksman",
	Description = "The Sigma-13 Sniper Rifle is the lighter cousin of the more popularly known SUF. While lacking the direct punch of the SUF, the S13 fires more quickly, is more readily available to WIJ forces and maintains the pinpoint accuracy of its larger variant.",
	QuickDescription = "Semi Automatic, Single Shot",
	WeaponCost = 1000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 1,
	EquipTime = 0.3,
	BatteryDepletionMin = 3,
	BatteryDepletionMax = 3,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 0,
	HeatRate = 30,
	CoolTime = 2,
	CoolWait = 1,
	Damage = 30,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 20,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0.1, -.5, -0.35) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		}
	},
}
