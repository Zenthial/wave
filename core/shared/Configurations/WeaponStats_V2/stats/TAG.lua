local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))

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

local Bullets = {
    Default = BulletAssets:WaitForChild("Default")
}

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    CollectionService:AddTag(Bullets.Default, "Ignore")
    Caches.DefaultCache = PartCache.new(Bullets.Default, 200)
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
	Name = "TAG",
	FullName = "Tag Stick",
	Category = "Melee",
	Description = "This version of the Stun Stick has been repurposed for recreational purposes. Compared to it's predecessor, this stick is capable of rendering it's target immobile for a near-infinite duration, but has been rendered non-lethal in any and every fashion. WIJ Alliance soldiers would often utilize this tool to play games such as Freeze Tag in their spare time, or during Training sessions.",
	QuickDescription = "Tagging Stick",
	WeaponCost = 0,
	AmmoType = AmmoType.Battery,
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	CanSprint = false,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = -5,
	EquipTime = 0.2,
	MinSpread = 0,
	MaxSpread = 0,
	HeatRate = 0,
	Damage = 0,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	ChargeWait = 0,
	Trigger = "Blade",
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.75, -.5) * CFrame.Angles(math.rad(-30), math.rad(-20), math.rad(180)),
			C1 = CFrame.new(),
		}
	},
}
