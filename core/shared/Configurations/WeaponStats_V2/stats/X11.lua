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
	Name = "X11",
	FullName = "Concentrated Particle Beam",
	Category = "Assault",
	Description = "This experimental assault rifle known as a ?pulsed beamer? due to its firing method is one of the latest fancy toys to come out of GORIUS R&D. This weapon uses a specially configured phase coil which emits light phase beams so quickly that the weapon could be mistaken for a sustained beam weapon.",
	QuickDescription = "Charged fire, Constanst Beam",
	WeaponCost = 5500,
	AmmoType = "Battery",
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	HeadshotMultiplier = 1.5,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 0,
	BatteryDepletionMin = 5,
	BatteryDepletionMax = 5,
	ShotsDeplete = 20,
	MaxSpread = 1,
	MinSpread = 0,
	HeatRate = 2,
	CoolTime = 4,
	CoolWait = 0.5,
	Damage = 6,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1.5,
	FireRate = 3,
	ChargeWait = 0.5,
	Trigger = "Semi",
	FireMode = "Constant",
	BulletType = "Constant",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(-0.1, -0.75, -0.45) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
