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
	Name = "Y16",
	FullName = "Automatic Phaser Pistol",
	Category = "Handgun",
	Description = "The YOLTOR no. 16 is a weighty weapon as far as sidearms are concerned. While the technology in this pistol is often ridiculed by its competitors as unreliable and inefficient, and often troops will favor its older cousin the Y14, the Y16 has an advantage over any other WIJ pistol in that it fires automatically, much like many WIJ assault rifles.",
	QuickDescription = "Automatic, Single Shot",
	WeaponCost = 750,
	AmmoType = "Battery",
	Slot = 2,
	Holster = Holsters.Hip,
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
	ShotsDeplete = 10,
	MaxSpread = 3,
	MinSpread = 0.5,
	HeatRate = 4,
	CoolTime = 3,
	CoolWait = 0.5,
	Damage = 7,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 10,
	ChargeWait = 0,
	Trigger = "Auto",
	FireMode = "Single",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0,-.5,-.25) * CFrame.Angles(math.rad(-90),0,0),
			C1 = CFrame.new()
		}
	},
}
