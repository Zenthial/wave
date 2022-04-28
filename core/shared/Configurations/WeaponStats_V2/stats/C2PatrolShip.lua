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
	Name = "C2PatrolShip",
	FullName = "Charged Railgun",
	Category = "Explosive",
	Description = "It was supposed to be a joke. Then everything went wrong.",
	QuickDescription = "Semi Automatic, Single Explosise Beam",
	WeaponCost = 999999999,
	NumBarrels = 2,
	CanTeamKill = true,
	ShotsDeplete = 0,
	MaxSpread = 10,
	CoolTime = 8,
	Damage = 50,
	VehicleMultiplier = 1,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	FireRate = 8,
	ChargeWait = 0.5,
	Trigger = "Auto",
	FireMode = FireMode.SingleShipExplosive,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

}
