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
