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
	Name = "AT",
	FullName = "Anti-Armor Charged Phaser",
	Category = "Explosive",
	Description = "When it comes to dispatching armor on foot, the AT Anti-Armor Phaser is the solution. With the increasing use of armored units by hostile forces against WIJ strongholds, the use of the AT Anti-Armor Phaser has grown. Hundreds of these weapons were airdropped into CASTLE Cobalt during the great siege of the last century.",
	QuickDescription = "Charged Shot",
	WeaponCost = 3750,
	AmmoType = "Battery",
	Slot = 1,
	Holster = Holsters.Back,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = 3,
	BatteryDepletionMin = 20,
	BatteryDepletionMax = 20,
	ShotsDeplete = 1,
	MaxSpread = 2,
	MinSpread = 1,
	HeatRate = 100,
	CoolTime = 3,
	CoolWait = 0,
	Damage = 50,
	CalculateDamage = function(damage, distance)
		return damage + (50 * (1/distance))
	end,
	VehicleMultiplier = 30,
	BlastRadius = 30,
	FireRate = 3,
	ChargeWait = 2,
	Trigger = "Semi",
	FireMode = "SingleExplosive",
	BulletType = "Ray",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(.5, -1, -1.25) * CFrame.Angles(math.rad(0),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
