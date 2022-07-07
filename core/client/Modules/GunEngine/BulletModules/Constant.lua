local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local PartCache = require(Shared:WaitForChild("util"):WaitForChild("PartCache"))

type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local CF_REALLY_FAR_AWAY = CFrame.new(0, 10e8, 0)

local Constant = {}
Constant.__index = Constant
Constant.__Tag = "Constant"

function Constant.new(gunModel: GunModel, weaponStats)
    local storedBullet = weaponStats.BulletCache:GetPart()
    storedBullet.CFrame = CF_REALLY_FAR_AWAY
    
    local self = setmetatable({
        GunModel = gunModel,
        WeaponStats = weaponStats,
        StoredBullet = storedBullet,        
        
        Cleaner = Trove.new()
    }, Constant)

    return self
end

function Constant:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            Constant.StaticDraw(gunModel.Barrel.Position, target, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Constant.StaticDraw(startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    math.randomseed(tick())

    
end

function Constant:Destroy()
    self.Cleaner:Destroy()
end

return Constant
