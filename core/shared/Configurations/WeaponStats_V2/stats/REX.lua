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
	Name = "REX",
	FullName = "Rapid Phaser Minigun",
	Category = "Restricted",
	Description = "The REX is a high powered mini-gun capable of both legendary fire rate and damage against targets. Only a small number of these miniguns exist in the hands of HICOM councillors and bodyguards, due to the exorbitant cost of the starship-grade technology used ( the REX is in essence a point defense phaser downsized to be carried by a trooper) and the fact the science to build these beastly miniguns is known to only a few specific manufacturing personnel at any given time.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 150000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 3,
	CanSprint = false,
	CanCrouch = false,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 5,
	EquipTime = 0.5,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 15,
	MaxSpread = 1,
	MinSpread = 0.7,
	HeatRate = 0.75,
	CoolTime = 7,
	CoolWait = 0.3,
	Damage = 7,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 6,
	FireRate = 13,
	ChargeWait = 0.5,
	Trigger = "Auto",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(.25, -2, -1.25) * CFrame.Angles(math.rad(-135),math.rad(180),0),
			C1 = CFrame.new()
		},
	},
}
