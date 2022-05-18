local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
-- all of the below tables, except the caches, are just enums

local FireMode = {
    Single = "Single",
    Shotgun = "Shotgun",
    Burst = "Burst",
}

local BulletType = {
    Ray = "Ray",
    Streak = "Streak",
    Projectile = "Projectile",
}

local AmmoType = {
    Battery = "Battery",
    Ammo = "Ammo"
}

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
            Caches.DefaultCache = PartCache.new(bullet, 50)
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
	Name = "COOKIE",
	FullName = "Cookie",
	Category = "Misc",
	Description = "An ancient edible dating several millenia, said to be prevalent among many cultures. The most common design for a cookie is a simple and flat, hand-held circle, often decorated with sugar-based products such as chocolate.",
	QuickDescription = "",
	WeaponCost = 1000,
	AmmoType = AmmoType.Battery,
	Slot = 1,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 2,
	EquipTime = 0.3,
	ChargeWait = 0,
	Trigger = "Consumable",
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -1.2, -.5) * CFrame.Angles(math.rad(225), 0, math.rad(0)),
			C1 = CFrame.new()
		}
	},
}
