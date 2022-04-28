local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
-- all of the below tables, except the caches, are just enums
local GunTypes = {
    Auto = "Auto",
    Semi = "Semi",
}

local FireMode = {
    Single = "Single",
    Shotgun = "Shotgun",
    Burst = "Burst",
}

local BulletType = {
    Ray = "Ray",
    Lighting = "Lighting",
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
    local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile")
    if bullet then
        CollectionService:AddTag(bullet, "Ignore")
        Caches.DefaultCache = PartCache.new(bullet, 50)
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
	Name = "PFC",
	FullName = "Poppy's Fried Chicken",
	Category = "Misc",
	Description = "A culturally significant cuisine originating from the Federation, a bucket of Poppy's Fried Chicken (made with some indeterminate number of herbs and spices) is highly treasured by it's consumers. So treasured that people would literally riot in the streets at the mere mention of it's disposal from literally anywhere... uhh what?",
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
