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
	Name = "W17",
	FullName = "Assault Rifle",
	Category = "Assault",
	Description = "The WIJ Mark 17 Individual Defense and Combat Initiator has proven to be effective under many combat scenarios. It is a highly popular rifle throughout the WIJ forces, as it is very durable. The W17 Assault Rifle is produced on the planet Gorius 5 by GORIUS ARMORIES for the WIJ Corporation.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 0,
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
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 10,
	MaxSpread = 2.5,
	MinSpread = 0.5,
	HeatRate = 2,
	CoolTime = 3,
	CoolWait = 0.3,
	Damage = 7,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 11,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = "Single",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		},
	},
}
