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
	Name = "SUF",
	FullName = "Sniper Rifle",
	Category = "Marksman",
	Description = "The Sigma ?Ultimate Force? Sniper Rifle is the definition of long-range elimination in the WIJ arsenal. It boasts a formidable weapons discharge capable of killing or vaporizing a target several kilometers away and is virtually unable to miss the spot it is fired at.",
	QuickDescription = "Semi Automatic, Single Shot",
	WeaponCost = 2700,
	AmmoType = "Battery",
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 0,
	BatteryDepletionMin = 5,
	BatteryDepletionMax = 5,
	ShotsDeplete = 1,
	MaxSpread = 1,
	MinSpread = 0,
	HeatRate = 50,
	CoolTime = 4,
	CoolWait = 2.25,
	Damage = 45,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 3,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = "Single",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(-0.1, -.75, -0.45) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
