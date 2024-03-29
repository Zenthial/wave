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
	Name = "R87",
	FullName = "Charged Railgun",
	Category = "Explosive",
	Description = "The HilTech Type 87 Heavy Assault Rifle is classified as a 'Charged Railgun' which fires ultra-high intensity phaser bolts at its target. The bolts explode on impact with the surface they hit, and due to their higher energy yield can pierce through cover, hitting any unfortunate enemy that is directly behind said cover.",
	QuickDescription = "Semi Automatic, Single Explosise Beam",
	WeaponCost = 5000,
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
	BatteryDepletionMin = 3,
	BatteryDepletionMax = 4,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 1,
	HeatRate = 35,
	CoolTime = 4,
	CoolWait = 0,
	VehicleMultiplier = 10,
	Damage = 20,
	CalculateDamage = function(damage, distance)
		damage = damage + (10 * (1/(distance/3)))
		return math.clamp(damage, 20, 35)
	end,
	BlastRadius = 10,
	FireRate = 3,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = "SingleExplosive",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.75, -0.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		},
	},
}
