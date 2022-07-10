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
	Name = "ENHC-S",
	FullName = "Shield Overcharger",
	Category = "Suit module",
	Description = "The Enhanced Capacitor Shield harness is a special device which is fitted over the normal armor of a trooper. The device consists of a shield overcharge matrix which hooks into shield implants and armor-based shield generators, and holds a capacitor which when activated, feeds a constant overcharge into the wearer's shield systems.",
	QuickDescription = "Damage Resistance",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Press",
	WalkspeedReduce = 2,
	Damage = 0.5,
	EnergyDeplete = 2,
	EnergyRegen = 2,
	EnergyMin = 20,
}
