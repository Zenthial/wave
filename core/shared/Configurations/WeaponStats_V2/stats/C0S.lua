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
	Name = "C0S",
	FullName = "Distortion Grenade",
	Category = "Grenade",
	Description = "The Caustic Obliteration Sphere Grenade is a specialized area-denial munition. Once thrown and activated the grenade quickly disperses large amounts of heat and plasma within a contained area. Personnel caught in the area of effect are quickly chewed through, taking damage until they are able to escape the field or are dissolved by the plasma.",
	QuickDescription = "Temporary Constant Area Damage",
	WeaponCost = 1500,
	Slot = 3,
	Type = "Projectile",
	CanTeamKill = false,
	Locked = false,
	Damage = 2,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage + (20 * (1 / distance)), 1, 15)
	end,
	VehicleMultiplier = 0.2,
}
