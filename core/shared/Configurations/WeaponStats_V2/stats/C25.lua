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
	Name = "C25",
	FullName = "Plasma Grenade Launcher",
	Category = "Assault",
	Description = "It shoot's C0S's. Maybe.",
	QuickDescription = "Single Constant damage Projectile",
	WeaponCost = 3000,
	AmmoType = "Battery",
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 2,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 2,
	BatteryDepletionMin = 3,
	BatteryDepletionMax = 5,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 4,
	HeatRate = 2,
	CoolTime = 2,
	CoolWait = 1,
	FireRate = 0.2,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = "Launcher",
	BulletType = "Projectile",
	BulletCache = Caches.DefaultCache,

	Damage = 2,
	CalculateDamage = function(damage, distance)
		return math.clamp(damage + (10 * (1 / distance)), 1, 15)
	end,
	VehicleMultiplier = 0.5,
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -.25, -.5) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
