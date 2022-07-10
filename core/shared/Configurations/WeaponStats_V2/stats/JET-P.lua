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
	Name = "JET-P",
	FullName = "Vertical Boost Jets",
	Category = "Suit module",
	Description = "The Jet Pack is a special harness mounted to the back of the normal armor of a trooper. Two heavy duty fusion thrusters direct plasma and permit a soldier to fly far over a battlefield and eventually land safely, granting them a significant tactical advantage over hostiles in the area.",
	QuickDescription = "Fast Vertical Boost, Limited Mobility",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Hold",
	EnergyDeplete = 12,
	EnergyRegen = 3,
	EnergyMin = 12,
}
