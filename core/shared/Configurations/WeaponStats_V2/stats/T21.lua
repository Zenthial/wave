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
	Name = "T21",
	FullName = "Automatic Shotgun",
	Category = "Shotgun",
	Description = "The T21 Automatic Shotgun is a variant of the T11. This model trades a heavy disruption coil for a lighter, more rapid fire model backed up by a drum-magazine battery. This allows close quarters combatants to keep up the pressure during their engagements.",
	QuickDescription = "Automatic, 5 Pellet Shots",
	WeaponCost = 1900,
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
	EquipTime = 0.3,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 10,
	MaxSpread = 10,
	MinSpread = 4,
	HeatRate = 3.5,
	CoolTime = 2.5,
	CoolWait = 0.5,
	Damage = 20,
	CalculateDamage = function(damage, distance)
		if distance <= 50 then
			damage = 20 + (0.015 * ((distance - 50)^2)) - (0.18 * distance)
		end
		return damage / 3
	end,
	VehicleMultiplier = 1,
	FireRate = 4,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = FireMode.Shotgun,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0,0,0) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		}
	},
}
