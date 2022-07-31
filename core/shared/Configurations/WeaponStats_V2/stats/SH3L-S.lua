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
	Name = "SH3L-S",
	FullName = "Medical Nanite Dispenser",
	Category = "Suit module",
	Description = "The Self Heal System is a special implant mounted in close proximity to the heart, lungs and other vital organs of a trooper. When the trooper is physically damaged by enemy fire, the device can be activated, sending a stream of healing nanites directly through the bloodstream to damaged areas.",
	QuickDescription = "Self Healing",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Hold",
	Heal = 5,
	EnergyDeplete = 3,
	EnergyRegen = 2,
	EnergyMin = 40,
}
