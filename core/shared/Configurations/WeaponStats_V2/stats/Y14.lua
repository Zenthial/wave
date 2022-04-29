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
	Name = "Y14",
	FullName = "Phaser Pistol",
	Category = "Handgun",
	Description = "The YOLTOR no. 14 phaser pistol is the standard-issue sidearm issued to all WIJ forces with a history dating back to the conception of the alliance. With a highly efficient energy converter and easy handling, the Y14 serves well in any combat situation. The Y14 is widely considered the best sidearm on the market today.",
	QuickDescription = "Semi Automatic, Single Shot",
	WeaponCost = 0,
	AmmoType = AmmoType.Battery,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 1.6,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 0,
	EquipTime = 0.1,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 10,
	MaxSpread = 2.5,
	MinSpread = 0.5,
	HeatRate = 5,
	CoolTime = 1.5,
	CoolWait = 1,
	Damage = 8,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 15,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0,-.5,-.25) * CFrame.Angles(math.rad(-90),0,0),
			C1 = CFrame.new()
		}
	},
}
