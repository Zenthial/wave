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
	Name = "G25",
	FullName = "Plasma Grenade Launcher",
	Category = "Assault",
	Description = "The G25 Triggered Grenade Launcher is unlike all other weapons in WIJ's arsenal due to it firing a charged particle as opposed to a directed phaser. The weapon is renowned for being particularly tricky to use however those familiar with its nature can tap into its lethal nature by laying traps and disrupting the movement of enemy units.",
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
	Locked = false,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	BatteryDepletionMin = 12.5,
	BatteryDepletionMax = 12.5,
	ShotsDeplete = 1,
	MaxSpread = 1,
	MinSpread = 1,
	HeatRate = 100,
	CoolTime = 4,
	CoolWait = 1,
	FireRate = 0,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Launcher,
	BulletType = BulletType.Projectile,
	BulletCache = Caches.DefaultCache,

	Damage = 55,
	CalculateDamage = function(damage, distance)
		damage = damage + (60 /distance)
		return math.clamp(damage, 50, 75)
	end,
	VehicleMultiplier = 10,
	BlastRadius = 20,
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.25, -.5) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
