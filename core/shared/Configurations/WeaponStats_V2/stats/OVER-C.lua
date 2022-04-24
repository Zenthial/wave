local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))

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

local Bullets = {
    Default = BulletAssets:WaitForChild("Default")
}

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    CollectionService:AddTag(Bullets.Default, "Ignore")
    Caches.DefaultCache = PartCache.new(Bullets.Default, 200)
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
	Name = "OVER-C",
	FullName = "Weapon overclocker",
	Category = "Suit module",
	Description = "The OVER-Clocker is a compact module that is capable of, in a sense, 'overclocking' a weapon's phaser coils by overloading them to a near-critical state. The subsequently volatile plasma reaction significantly boosts the weapon's fire rate and phaser output, but sacrifices a large amount of accuracy due to the sheer recoil caused. Additionally, this reaction also puts much greater strain on the weapon's battery, draining it and overheating significantly faster than it's usual state. As such, the OVER-C is not intended to be used conventionally on a frequent basis, only when the moment calls for it.",
	QuickDescription = "Weapon overclocker",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Press",
	EnergyDeplete = 5,
	EnergyRegen = 2,
	EnergyMin = 10,
}
