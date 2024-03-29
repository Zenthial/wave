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
	Name = "SWD",
	FullName = "Power Sword",
	Category = "Melee",
	Description = "The SWD Power Sword device is not a blade but in reality a small hand-held plasma and force field generator. When activated the device flash-forges a searing hot blade of high temperature plasma, contained by forcefields to give it both physical tangibility and a sharpness meeting and exceeding that of the finest carbon nanotube blades utilized by non-WIJian species.",
	QuickDescription = "Plasma blade",
	WeaponCost = 300,
	AmmoType = "Battery",
	Slot = 2,
	Holster = Holsters.Hip,
	NumHandles = 1,
	CanSprint = false,
	CanCrouch = true,
	CanTeamKill = false,
	Locked = false,
	WalkspeedReduce = -7,
	MinSpread = 0,
	MaxSpread = 0,
	HeatRate = 0,
	Damage = 60,
	CalculateDamage = function(damage, distance)
		return damage
	end,
	VehicleMultiplier = 1,
	ChargeWait = 0,
	Trigger = "Blade",
	HandleWelds = {
		{	limb = "Right Arm",
			C0 = CFrame.new(0, -0.75, -0.5) * CFrame.Angles(math.rad(-30), math.rad(-20), math.rad(180)),
			C1 = CFrame.new(),
		}
	},
}
