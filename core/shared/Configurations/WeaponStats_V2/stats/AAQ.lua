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
	Name = "AAQ",
	FullName = "Automated Targeting Deployable Turret",
	Category = "Deployable",
	QuickDescription = "Automatic, Single Shot",
	Description = "The Aggressive Automated Quick reactor is a sophisticated light-armoured turret defense system. Outfitted with a proximity sensor, the AAQ is designed to neutralize or suppress any hostile entities that wander within range of its rapid-fire phaser coil.",
	WeaponCost = 5000,
	Slot = 3,
	Type = "Deployable",
	CanTeamKill = false,
	Locked = true,
	DeployTime = 1.5,
	TeamKillPrevention = true,
	MaxSpread = 7,
	MinSpread = 5,
	Damage = 2,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
	FireRate = 10,
	ChargeWait = 0,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

}
