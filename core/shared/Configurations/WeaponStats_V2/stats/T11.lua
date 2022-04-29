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
    if weapon then
        local bullet = weapon:FindFirstChild("Bullet") or weapon:FindFirstChild("Projectile")
        if bullet then
            CollectionService:AddTag(bullet, "Ignore")
            Caches.DefaultCache = PartCache.new(bullet, 50)
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
	Name = "T11",
	FullName = "Shotgun",
	Category = "Shotgun",
	Description = "The T11 Tactical Shotgun is a close-in weapon used in breach and clear engagements. The electromagnetic disruption provided by one shot of the T11 equates that of an entire squad firepower and can potentially vaporize a soldier in one shot. However the heavy EM flux used to generate this powerful disruption blast degrades very fast over distance.",
	QuickDescription = "Semi Automatic, 5 Pellet Shots",
	WeaponCost = 500,
	AmmoType = AmmoType.Battery,
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
	EquipTime = 0.3,
	BatteryDepletionMin = 2,
	BatteryDepletionMax = 3,
	ShotsDeplete = 10,
	MaxSpread = 6,
	MinSpread = 4,
	HeatRate = 4,
	CoolTime = 2,
	CoolWait = 1.2,
	Damage = 100,
	CalculateDamage = function(damage, distance)
		if distance >= 2 then
			damage = 25
			if distance <= 50 then
				damage = 80 + (0.035 * ((distance-25)^2)) - (1.5375 * distance)
			end
		end
		return damage / 5
	end,
	VehicleMultiplier = 1,
	FireRate = 4,
	ChargeWait = 0,
	Trigger = "Semi",
	FireMode = FireMode.Shotgun,
	BulletType = BulletType.Ray,
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
			C1 = CFrame.new()
		}
	},
}
