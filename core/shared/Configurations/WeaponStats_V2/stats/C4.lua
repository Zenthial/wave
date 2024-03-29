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
	Name = "C4",
	FullName = "Plasma Charges",
	Category = "Deployable",
	Description = "When the utmost in breaching and destructive power is necessary, the humble C4 Explosive, a stable and reliable explosive munition is the tool for the job. While the explosive can be damaged and destroyed by fire, only by using a special detonation system packaged with the C4 can actually trigger its explosive effects.",
	QuickDescription = "Detonateable, Area Damage",
	WeaponCost = 1000,
	Slot = 3,
	Type = "Deployable",
	CanTeamKill = false,
	Locked = false,
	DeployTime = 0.5,
	TeamKillPrevention = true,
	Damage = 250,
	CalculateDamage = function(damage, distance)
		damage = damage + (250 /distance)
		return math.clamp(damage, 50, 75)
	end,
	VehicleMultiplier = 5,
	BlastRadius = 15,
}
