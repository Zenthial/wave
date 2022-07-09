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
	Name = "APS",
	FullName = "Active Protection System",
	Category = "Suit module",
	Description = "The ?APS? deflector screen projection harness is a special device manufactured by a less mentally stable sect of GORIUS Armories engineers. The APS, when activated, deploys a projected barrier covering the front arc of the trooper using it.",
	QuickDescription = "Shot Blocking Shield",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.TorsoModule,
	Trigger = "Press",
	EnergyDeplete = 2,
	EnergyRegen = 2,
	EnergyMin = 30,
}
