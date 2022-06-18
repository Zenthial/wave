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

            local cacheFolder = Instance.new("Folder")
            cacheFolder.Name = script.Name .. "Cache"
            cacheFolder.Parent = workspace:WaitForChild("BulletCaches")
            Caches.DefaultCache = PartCache.new(bullet, 50, cacheFolder)
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
	Name = "MTA-S",
	FullName = "Anti-Infantry Deployable Turret",
	Category = "Deployable",
	QuickDescription = "Automatic, Single Shot",
	Description = "The Mobile Turret Assembly System is a ready-made engineering package which is capable of deploying a vehicle-grade turret at the position of unpacking. The turret’s phaser systems are reliable, quite durable, and capable of putting down potent fire at considerable range.",
	WeaponCost = 2000,
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
	DeployTime = 1,
	TeamKillPrevention = false,
	MaxSpread = 1,
	MinSpread = 0.5,
	HeatRate = 0.75,
	CoolTime = 6,
	CoolWait = 0.3,
	Damage = 11,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
	FireRate = 10,
	ChargeWait = 0.5,
	Trigger = "Auto",
	FireMode = FireMode.Single,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

}
