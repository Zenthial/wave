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
    local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile")
    if bullet then
        CollectionService:AddTag(bullet, "Ignore")
        Caches.DefaultCache = PartCache.new(bullet, 50)
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
	Name = "SP0T-R",
	FullName = "Hostile Detection Module",
	Category = "Suit module",
	Description = "The Spotter is a high sensitivity telemetry and sensing package which conveniently mounts onto the arm of a reconnaissance unit. When activated the device sends forth a wave of deep penetrating scans on variable frequencies, permitting the user to spot enemies who are hidden behind cover or concealment.",
	QuickDescription = "Hostile Marking",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.LeftArmModule,
	Trigger = "Hold",
	EnergyDeplete = 100,
	EnergyRegen = 1,
	EnergyMin = 99,
}
