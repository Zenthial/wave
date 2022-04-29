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
	Name = "H23",
	FullName = "Revolver",
	Category = "Handgun",
	Description = "The HilTech Type-23 Revolver is a heavy duty phaser pistol favored among border worlds enforcement agencies and criminal forces alike. Shot per shot the phase coils in the H23 are heavier than its YOLTOR competitors, capable of putting out the pain where it counts. The H23 is a bit more unwieldy than its competitors however.",
	QuickDescription = "Semi Automatic, Single Shot",
	WeaponCost = 1250,
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
	EquipTime = 0.1,
	BatteryDepletionMin = 4,
	BatteryDepletionMax = 5,
	ShotsDeplete = 10,
	MaxSpread = 1,
	MinSpread = 0.5,
	HeatRate = 10,
	CoolTime = 3,
	CoolWait = 0.5,
	Damage = 13,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 10,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -1.15, 0) * CFrame.Angles(math.rad(-90),0,0),
			C1 = CFrame.new()
		}
	},
}