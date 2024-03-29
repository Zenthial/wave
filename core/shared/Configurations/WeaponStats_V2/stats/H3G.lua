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
	Name = "H3G",
	FullName = "Nanite Delivery Grenade",
	Category = "Grenade",
	Description = "The Helios Mk. 3 Grenade is a specialized grenade issued to WIJ medical operatives.  It has very simple and easy to use code keys which ensure proper usage of the ordnance. Upon being thrown the grenade releases its payload of healing nanites, which affix to any allied personnel in the area and effect healing immediately.",
	QuickDescription = "Radial Healing Effect",
	WeaponCost = 1500,
	Slot = 3,
	Type = "Projectile",
	Action = "Heal",
	CanTeamKill = true,
	Locked = false,
	Heal = 50,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	BlastRadius = 25,
}
