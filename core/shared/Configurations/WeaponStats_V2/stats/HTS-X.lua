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
	Name = "HTS-X",
	FullName = "Hydraulic Turret System",
	Category = "",
	Description = "", -- Turret tool for GROWLER, no desc needed,
	QuickDescription = "Semi Automatic, Single Explosive Shot",
	WeaponCost = 3000,
	Slot = 3,
	DeltaSlot = 5,
	Type = "Deployable",
	NumBarrels = 3,
	CanSprint = false,
	CanCrouch = false,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 0,
	EquipTime = 0,
	MaxSpread = 1,
	MinSpread = 0.5,
	HeatRate = 40,
	CoolTime = 6,
	CoolWait = 1,
	Damage = 70,
	VehicleMultiplier = 10,
	CalculateDamage = function(damage, distance)
		return damage + (40 * (1/distance))
	end,
	BlastRadius = 30,
	FireRate = 10,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Launcher,
	BulletType = BulletType.Projectile,
	BulletCache = Caches.DefaultCache,

}
