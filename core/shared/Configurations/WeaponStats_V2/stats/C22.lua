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
	Name = "C22",
	FullName = "Dual Wielded HandCannons",
	Category = "Handgun",
	Description = "The C22 'lockphaser', a calling back to the bullet based projectile weapons of old, is a simple yet elegant piece capable of putting clean holes in its targets, the gun itself infamous for its special cocking mechanism which must be primed to prepare the phase coil for firing each time.",
	QuickDescription = "Semi Automatic, 4 Pellet Shots",
	WeaponCost = 4000,
	AmmoType = AmmoType.Battery,
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
	BatteryDepletionMin = 4,
	BatteryDepletionMax = 6,
	ShotsDeplete = 10,
	MaxSpread = 5,
	MinSpread = 4,
	HeatRate = 7,
	CoolTime = 2,
	CoolWait = 0.5,
	Damage = 5,
	CalculateDamage = function(damage, distance)
		if distance<=20 then
			damage=15+(80*(1/distance+.6))
			damage=damage/4.5
		end
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 4,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Shotgun,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.35, -.4) * CFrame.Angles(0,0,math.rad(180)),
			C1 = CFrame.new()
		},
		{	limb = "Left Arm",
			C0 = CFrame.new(0, -.35, -.4) * CFrame.Angles(0,0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
