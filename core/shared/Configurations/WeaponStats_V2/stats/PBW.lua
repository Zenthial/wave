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
	Name = "PBW",
	Category = "Marksman",
	Description = "This is an exceptionally bizarre weapon and a very recent addition to the WIJ arsenal.The Plasma Bow consists of a compound bow frame fitted with a plasma generator and sights. Pulling back the charged string causes a reaction that literally synthesizes a forcefield-encased plasma bolt between the fingers of the user.",
	QuickDescription = "Charged Single Projectile",
	WeaponCost = 3400,
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
	WalkspeedReduce = 0,
	EquipTime = 0.2,
	BatteryDepletionMin = 2.5,
	BatteryDepletionMax = 2.5,
	ShotsDeplete = 1,
	MaxSpread = 1,
	MinSpread = 1,
	HeatRate = 100,
	CoolTime = 0.75,
	CoolWait = 1,
	FireRate = 0,
	ChargeWait = 0.5,
	Trigger = "Semi",
	FireMode = FireMode.Launcher,
	BulletType = BulletType.Projectile,
	BulletCache = Caches.DefaultCache,

	Damage = 40,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 2,
	BlastRadius = 10,
	HandleWelds = {
		{	limb = "Left Arm",
			C0 = CFrame.new(.25, -0.75, 0) * CFrame.Angles(math.rad(-90), math.rad(-100), 0),
			C1 = CFrame.new()
		}
	},
}
