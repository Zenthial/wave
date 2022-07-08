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
local OnRayHit, OnRayBounced, OnRayUpdated, OnRayTerminated, CanRayBounce, CastBehavior, HandleProjectileStats = HelperFunctions.OnRayHit, HelperFunctions.OnRayBounced, HelperFunctions.OnRayUpdated, HelperFunctions.OnRayTerminated, HelperFunctions.CanRayBounce, HelperFunctions.CastBehavior, HelperFunctions.HandleGadgetStats

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
            Projectile.StaticDraw(Players.LocalPlayer, gunModel.Barrel.Position, target, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Projectile.StaticDraw(player: Player, startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    local bullet = bulletCache:GetPart() :: BasePart
    CollectionService:AddTag(bullet, "Ignore")

    handleProjectileStats(player, NadeCaster, CastParams,  
end

function Projectile:Destroy()
    self.Cleaner:Clean()
end

return Projectile
