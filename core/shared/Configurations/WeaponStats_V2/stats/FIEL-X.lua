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
	Name = "FIEL-X",
	FullName = "Shock Field Generator",
	Category = "Suit module",
	QuickDescription = "Area Damage",
	Description = "The Field Generator X is a special harness mounted to one of the arms, or other relevant appendages, of a trooper. Upon activation, the device effectively amplifies the wearer?s arm strength by a large factor by generating a phased energy field around it.",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.RightArmModule,
	Trigger = "Press",
	Damage = 60,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage * (10/distance), 0, 60)
	end,
	VehicleMultiplier = 2,
	BlastRadius = 15,
	EnergyDeplete = 100,
	EnergyRegen = 3,
	EnergyMin = 99,
}
