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
        local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile")
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
	Name = "STAS3N",
	FullName = "Deployable Healing Station",
	Category = "Deployable",
	Description = "The [Station] is a ready-made engineering package which is capable of deploying a healing station at the position of unpacking. As long as the device is functional, it will stream healing nanites into friendly units, keeping them fit for duty on the front lines of a battle.",
	QuickDescription = "Constant Area Healing Effect",
	WeaponCost = 2000,
	Slot = 3,
	Locked = false,
	Type = "Deployable",
	CanTeamKill = true,
	DeployTime = 1.5,
	TeamKillPrevention = true,
	Heal = 2.5,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 5,
    Quantity = 2,
	BlastRadius = 20,
}
