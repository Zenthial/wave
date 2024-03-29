local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
-- all of the below tables, except the caches, are just enums

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    local weapon = Weapons:FindFirstChild(script.Name)
    if weapon then
        local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile") bullet.CastShadow = false
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
	Name = "VOL",
	FullName = "Scorpius Volatile Incendiary Projector",
	Category = "Deployable",
	QuickDescription = "Flame Turret",
	Description = "Scorpius' Volatile Incendiary Projector is a light-armoured turret defense system outfitted with a miniaturized plasma thrower. The VOL is best used for point defense and performs well against organic targets.",
	WeaponCost = 5000,
	Slot = 3,
	Type = "Deployable",
	CanTeamKill = false,
	Locked = false,
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
	BulletType = "Flame",
	BulletCache = Caches.DefaultCache,

}
