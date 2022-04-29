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

local Ray = {}
Ray.__index = Ray
Ray.__Tag = "Ray"

function Ray.new(gunModel: GunModel, weaponStats)
    local self = setmetatable({
        GunModel = gunModel,
        WeaponStats = weaponStats,

        Cleaner = Trove.new()
    }, Ray)
    return self
end

function Ray:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            Ray.StaticDraw(gunModel.Barrel.Position, target, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Ray.StaticDraw(startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    local bullet = bulletCache:GetPart() :: BasePart
    CollectionService:AddTag(bullet, "Ignore")
    
    local iDist = (endPosition - startPosition).Magnitude
    
    local oldBulletScale = bullet.Mesh.Scale
    bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    local oldBulletCFrame = bullet.CFrame
    bullet.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    
    local x = bullet.Mesh.Scale.X
    local y = bullet.Mesh.Scale.Y
    local z = bullet.Mesh.Scale.Z
    local bullet2 = bulletCache:GetPart()
    local oldBullet2Offset = bullet2.Mesh.Offset
    bullet2.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    bullet2.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    local scale = z * .5
    local offset = -z * .25
    if z > 100 then
        scale = z - 50
        offset = -50
    end
    bullet2.Mesh.Scale = Vector3.new(x, y, scale)
    bullet2.Mesh.Offset = Vector3.new(0, 0, offset)
    
    task.delay(.05, function()
        bullet.Mesh.Scale = oldBulletScale
        bullet.CFrame = oldBulletCFrame
        bulletCache:ReturnPart(bullet)
    end)

    task.delay(.1, function()
        bullet2.Mesh.Scale = oldBulletScale
        bullet2.Mesh.Offset = oldBullet2Offset
        bullet2.CFrame = oldBulletCFrame
        bulletCache:ReturnPart(bullet2)
    end)
end

function Ray:Destroy()
    self.Cleaner:Destroy()
end

return Ray