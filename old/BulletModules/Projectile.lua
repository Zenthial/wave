local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local FastCast = require(ReplicatedStorage.Shared.Modules.FastCastRedux)

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local PartCache = require(Shared:WaitForChild("util"):WaitForChild("PartCache"))

local HelperFunctions = require(script.Parent.Parent.Grenades.helperFunctions)

local RNG = Random.new()	
local TAU = math.pi * 2 -- Set up mathematical constant Tau (pi * 2)

local NadeCaster = FastCast.new()
local OnRayHit, OnRayBounced, OnRayUpdated, OnRayTerminated, CanRayBounce, CastBehavior, HandleGadgetStats = HelperFunctions.OnRayHit, HelperFunctions.OnRayBounced, HelperFunctions.OnRayUpdated, HelperFunctions.OnRayTerminated, HelperFunctions.CanRayBounce, HelperFunctions.CastBehavior, HelperFunctions.HandleGadgetStats

NadeCaster.RayHit:Connect(OnRayHit)
NadeCaster.RayPierced:Connect(OnRayBounced)
NadeCaster.LengthChanged:Connect(OnRayUpdated)

local CastParams = RaycastParams.new()

local function MaxDistance(v, g, d, h)
	local m = h / d
	local v2 = v * v
	return (v2*math.sqrt(m*m + 1) - m*v2) / g
end

-- Compute 2D launch angle. First return value is true if within range, second is the angle.
-- v: launch velocity
-- g: gravity (positive) e.g. 196.2
-- d: horizontal distance
-- h: vertical distance
-- higherArc: if true, use the higher arc. If false, use the lower arc.
local function LaunchAngle(v: number, g: number, d: number, h: number, higherArc: boolean): (boolean, number)
	local max_x = MaxDistance(v, g, d, h)
	local v2 = v * v
	
	if d > max_x then
		return false, math.atan(v2 / (g * max_x))
	end
	
	local v4 = v2 * v2
	local root = math.sqrt(v4 - g*(g*d*d + 2*h*v2))
	if not higherArc then root = -root end
	return true, math.atan((v2 + root) / (g * d))
end

-- Compute 3D launch direction from. First return value is true if within range, second is the direction.
-- start: start position
-- target: target position
-- v: launch velocity
-- g: gravity (positive) e.g. 196.2
-- higherArc: if true, use the higher arc. If false, use the lower arc.
local function LaunchDirection(start, target, v, g, higherArc: boolean)
	-- get the direction flattened:
	local horizontal = Vector3.new(target.X - start.X, 0, target.Z - start.Z)
	
	local h = target.Y - start.Y
	local d = horizontal.Magnitude
	local inRange, a = LaunchAngle(v, g, d, h, higherArc)
	
	-- speed if we were just launching at a flat angle:
	local vec = horizontal.Unit * v
	
	-- rotate around the axis perpendicular to that direction...
	local rotAxis = Vector3.new(-horizontal.Z, 0, horizontal.X)
	
	-- ...by the angle amount
	return inRange, CFrame.fromAxisAngle(rotAxis, a) * vec
end

type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local Projectile = {}
Projectile.__index = Projectile
Projectile.__Tag = "Projectile"

function Projectile.new(gunModel: GunModel, weaponStats)
    local self = setmetatable({
        GunModel = gunModel,
        WeaponStats = weaponStats,

        Cleaner = Trove.new()
    }, Projectile)
    return self
end

function Projectile:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            Projectile.StaticDraw(Players.LocalPlayer, gunModel.Barrel.Position, target, self.WeaponStats.BulletCache, self.WeaponStats)

            return true
        end
    end

    return false
end

--[[
    Projectile's need an extra pointer to a GadgetStats table in their stats file
    This table will be used to create the projectile fired from the gun

    TerminationBehavior, which is a function called in the helperFunctions.lua module
    NumBounces, which is a number of how many times the projectile can bounce before exploding (default is 0)
    MaxDistance, which is how far the raycast can go
    Cache, which is the PartCache the caster should pull from 
    CacheFolder, which is the PartCache folder. this field should automatically be populated by grabbing the bulletCache's CurrentCacheParent value
    Gravity, how much gravity should effect the project
    ProjectileSpeed, how fast the projectile should be moving
    MinSpread, self explanatory
    MaxSpread, self explanatory
]]
function Projectile.StaticDraw(player: Player, startPosition: Vector3, direction: Vector3, bulletCache: PartCache.PartCache, weaponStats)
    local gadgetStats = weaponStats.GadgetStatsPointer
    gadgetStats.Cache = bulletCache
    gadgetStats.CacheFolder = bulletCache.CurrentCacheParent

    local inRange, direction = LaunchDirection(startPosition, direction, gadgetStats.ProjectileSpeed, math.abs(gadgetStats.Gravity.Y), false)
    
    HandleGadgetStats(player, NadeCaster, CastParams, gadgetStats)
    
    local directionalCF = CFrame.new(Vector3.new(), direction)
	direction = (directionalCF).LookVector
    -- local modifiedBulletSpeed = (direction * weaponStats.ProjectileSpeed) + movementSpeed	-- We multiply our direction unit by the bullet speed. This creates a Vector3 version of the bullet's velocity at the given speed. We then add MyMovementSpeed to add our body's motion to the velocity.

    local activeCast = NadeCaster:Fire(startPosition, direction, gadgetStats.ProjectileSpeed, CastBehavior)
	activeCast.UserData.SourceTeam = player.TeamColor
	activeCast.UserData.SourcePlayer = player
    activeCast.UserData.GadgetStats = gadgetStats
end

function Projectile:Destroy()
    self.Cleaner:Clean()
end

return Projectile
