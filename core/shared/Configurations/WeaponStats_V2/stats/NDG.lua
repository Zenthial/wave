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
	Name = "NDG",
	FullName = "Plasma Grenade",
	Category = "Grenade",
	Description = "The Nadion Detonation Grenade is the standard explosive grenade issued to WIJ forces. It has very simple and easy to use code keys which ensure proper usage of the ordnance. Upon being thrown the grenade begins a nadion cascade reaction, which results in a small explosion once it goes off.",
	QuickDescription = "Explosive",
	WeaponCost = 0,
	Slot = 3,
	Type = "Projectile",
	CanTeamKill = false,
	Locked = false,
	Damage = 50,
	CalculateDamage = function(damage, distance)
		damage = damage + (250 /distance)
		return math.clamp(damage, 50, 75)
	end,
	VehicleMultiplier = 4,
	BlastRadius = 15,
}
