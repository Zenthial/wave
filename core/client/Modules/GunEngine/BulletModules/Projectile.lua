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
    
    HandleGadgetStats(player, NadeCaster, CastParams, gadgetStats)
    
    local directionalCF = CFrame.new(Vector3.new(), direction)
	direction = (directionalCF * CFrame.fromOrientation(0, 0, RNG:NextNumber(0, TAU)) * CFrame.fromOrientation(math.rad(RNG:NextNumber(gadgetStats.MinSpread, gadgetStats.MaxSpread)), 0, 0)).LookVector
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
