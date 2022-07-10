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
	Name = "INVI-C",
	FullName = "Personal Cloaking Device",
	Category = "Suit module",
	Description = "The Invisibility Cloak harness is a special device mounted to the lower armor of a trooper. The device consists of a complex of advanced distortion technology which block a person?s electromagnetic profile, rendering them nearly invisible for a time. It is to be noted that a weapons discharge is enough to overload the device, resulting in the cloak field dropping.",
	QuickDescription = "Near Invisibility",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Press",
	EnergyDeplete = 2,
	EnergyRegen = 1,
	EnergyMin = 20,
}
