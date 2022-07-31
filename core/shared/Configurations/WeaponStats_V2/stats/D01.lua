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
	Name = "D01",
	FullName = "Orbital Target Designator-01",
	Category = "Assault",
	Description = "The ability for a squad commander to call in orbital fire support is invaluable. Once a target has been designated by the D01, a command is relayed to a appropriately equipped warship or satellite in orbit to fire its phaser array to a devastating effect, within seconds.",
	QuickDescription = "Single Shot",
	WeaponCost = 94000,
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
	BatteryDepletionMin = 100,
	BatteryDepletionMax = 100,
	ShotsDeplete = 1,
	MaxSpread = 2.5,
	MinSpread = 0.5,
	HeatRate = 100,
	CoolTime = 3,
	CoolWait = 0,
	Damage = 100,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 100,
	FireRate = 0,
	ChargeWait = 4,
	Trigger = "Semi",
	FireMode = "OrbitalStrike",
	BulletType = "OrbitalRay",
	BulletCache = Caches.DefaultCache,

	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90), 0 ,0),
			C1 = CFrame.new()
		},
	},
}
