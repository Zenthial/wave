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
	Name = "M1Z",
	FullName = "Proximity Mine",
	Category = "Deployable",
	Description = "The Mark 1 Zone Denial System is a quick deployment mechanism for a system of easily concealable, high impact land mines. Once placed the detonation mechanism of the mine arms, waiting for hostiles to get in just a bit too close before delivering a fatal explosive payload.",
	QuickDescription = "Area Damage",
	WeaponCost = 1000,
	Slot = 3,
	Locked = false,
	Type = "Deployable",
	CanTeamKill = false,
	DeployTime = 0.5,
    MaxDeployables = 6,
    Quantity = 2,
	TeamKillPrevention = true,
	Range = 7,
	Damage = 95,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
	BlastRadius = 15,
}
