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
	Name = "O73",
	FullName = "Octagon-7-3 Beam Pistol",
	Category = "Restricted",
	Description = "The O73 is an experimental pistol developed by Alpharus. An odd weapon, it does not fire phaser energy like conventional energy weapons. Instead it generates, slows down, and propels a constant beam of tachyon particles at the target. While the particles are easily stopped by modern shielding, the unique tech of the O73 allows it to continually bombard and ultimately kill a target. Due to its expense, only military officers are issued this weapon",
	QuickDescription = "Beam Pistol",
	WeaponCost = 5000,
	AmmoType = "Battery",
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 0,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 20,
	MaxSpread = 1,
	MinSpread = 0,
	HeatRate = 1.5,
	CoolTime = 2,
	CoolWait = 0.1,
	Damage = 3,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 2,
	FireRate = 0,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = "Constant",
	BulletType = "Constant",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.75, -0.25) * CFrame.Angles(math.rad(-90),0,math.rad(0)),
			C1 = CFrame.new()
		}
	},
}
