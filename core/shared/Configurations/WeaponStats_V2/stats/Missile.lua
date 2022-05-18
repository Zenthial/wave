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
	Name = "Missile",
	FullName = "Ballistic Missile",
	Category = "Explosive",
	Description = "",
	QuickDescription = "Explosive Projectile",
	WeaponCost = 3750,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	CanTeamKill = true,
	WalkspeedReduce = 3,
	EquipTime = 0.4,
	BatteryDepletionMin = 20,
	BatteryDepletionMax = 20,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 1,
	HeatRate = 100,
	CoolTime = 3,
	CoolWait = 0,
	Damage = 1000,
	CalculateDamage = function(damage, distance)
		return damage + (50 * (1/distance))
	end,
	VehicleMultiplier = 300,
	BlastRadius = 30,
	FireRate = 3,
	ChargeWait = 4,
	Trigger = "Semi",
	FireMode = FireMode.SingleExplosive,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(.5, -1, -1.25) * CFrame.Angles(math.rad(0),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
