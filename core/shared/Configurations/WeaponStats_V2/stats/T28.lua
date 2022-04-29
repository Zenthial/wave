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
	Name = "T28",
	FullName = "Double Barrel Shotgun",
	Category = "Shotgun",
	Description = "The T28 DB Shotgun is an example of taking a concept and pushing it to its outermost extremes.  By strapping two disruption coils side by side this weapons system is able to punish those who happen to be on the firing end of it.",
	QuickDescription = "Charged, 2 Shot Burst",
	WeaponCost = 4000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = false,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 10,
	MaxSpread = 4,
	MinSpread = 3,
	HeatRate = 7,
	CoolTime = 2,
	CoolWait = 0.3,
	Damage = 30,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 4,
	FireRate = 4,
	ChargeWait = 0.5,
	Trigger = "Auto",
	FireMode = FireMode.Shotgun,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -1.25,-.75) * CFrame.Angles(math.rad(-135),math.rad(180),0),
			C1 = CFrame.new()
		}
	},
}
