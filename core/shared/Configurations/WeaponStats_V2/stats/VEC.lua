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
	Name = "VEC",
	FullName = "Nanite Repair Dispenser",
	Category = "Support",
	Description = "The VEC Repair Tool is a highly advanced piece of kit for the WIJian engineer. Effectively a nano-welder, this handheld tool fires a beam of repair nanites which are capable of reconstituting the structure of any mechanical device, be it a vehicle or a building from anything short of a complete scrap heap.",
	QuickDescription = "Constant Vehicle Repair",
	WeaponCost = 1000,
	AmmoType = "Battery",
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	NumBarrels = 1,
	CanSprint = true,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = true,
	WalkspeedReduce = 2,
	BatteryDepletionMin = 1,
	BatteryDepletionMax = 3,
	ShotsDeplete = 20,
	MaxSpread = 0.5,
	MinSpread = 0.2,
	HeatRate = 1,
	CoolTime = 4,
	CoolWait = 0.25,
	Damage = -10,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	FireRate = 0,
	ChargeWait = 0,
	Trigger = "Semi",
	BulletType = "Constant",
	BulletCache = Caches.DefaultCache,

	FireMode = "Misc",
	Range = 15,
	Action = "Repair",
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(-0.1, -.75, -0.45) * CFrame.Angles(math.rad(90),0,math.rad(180)),
			C1 = CFrame.new()
		}
	},
}
