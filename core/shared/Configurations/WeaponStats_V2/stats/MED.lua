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
	Name = "MED",
	FullName = "Tissue Regenerator",
	Category = "Support",
	Description = "The Mark-ED Medical Facilitation tool is the most effective iteration of a series of handheld mediguns which have been replacing traditional first aid systems in the field. The MED fires a beam of medical nanites which coat the wounds of the patient and heal damage sustained in very short order.",
	QuickDescription = "Constant Health Regeneration",
	WeaponCost = 2000,
	AmmoType = AmmoType.Battery,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	CanTeamKill = true,
	Locked = false,
	HeadshotMultiplier = 4,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	BatteryDepletionMin = 1,
	BatteryDepletionMax = 3,
	ShotsDeplete = 20,
	MaxSpread = 0,
	MinSpread = 0,
	HeatRate = 1,
	CoolTime = 4,
	CoolWait = 0.25,
	Damage = -1,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 0,
	FireRate = 0,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Misc,
	BulletType = BulletType.Constant,
	BulletCache = Caches.DefaultCache,

	Action = "Heal",
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(-0.1, -1, -0.25) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
