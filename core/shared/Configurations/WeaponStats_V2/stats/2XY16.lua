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
	Name = "2XY16",
	FullName = "Dual Wielded Automatic Phaser Pistols",
	Category = "Handgun",
	Description = "When one Y16  is insufficient for mission requirements,officers and specialist forces such as the Shock Troopers are trained in the dual wielding of many of WIJ?s lighter infantry weapons. Being able to synchronize the fire of two weapons allows a trooper to put out twice the hurt he normally would be able to.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 2000,
	AmmoType = "Battery",
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 2,
	NumBarrels = 2,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 2,
	BatteryDepletionMin = 3,
	BatteryDepletionMax = 4,
	ShotsDeplete = 20,
	MaxSpread = 4,
	MinSpread = 1,
	HeatRate = 2,
	CoolTime = 3,
	CoolWait = 0.5,
	Damage = 7,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 15,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = "Single",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0,-.5,-.25) * CFrame.Angles(math.rad(-90),0,0),
			C1 = CFrame.new()
		},
		{	limb = "Left Arm",
			C0 = CFrame.new(0,-.5,-.25) * CFrame.Angles(math.rad(-90),0,0),
			C1 = CFrame.new()
		}
	},
}
