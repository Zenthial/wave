local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
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
local ACTIVE_BULLETS_TABLE = {}

local function getConstantBullets(player: Player, bulletCache: PartCache.PartCache, startTick: number)
    if ACTIVE_BULLETS_TABLE[player] ~= nil then
        return ACTIVE_BULLETS_TABLE[player]
    end

    local bullet1 = bulletCache:GetPart()
    CollectionService:AddTag(bullet1, "Ignore")
    local bullet2 = bulletCache:GetPart()
    CollectionService:AddTag(bullet2, "Ignore")

    local bulletTable = {
        Bullet1 = bullet1,
        Bullet2 = bullet2,
        Tick = startTick
    }

    ACTIVE_BULLETS_TABLE[player] = bulletTable
    return bulletTable
end

local Constant = {}
Constant.__index = Constant
Constant.__Tag = "Constant"

function Constant.new(gunModel: GunModel, weaponStats) 
    local self = setmetatable({
        GunModel = gunModel,
        WeaponStats = weaponStats,
        
        Cleaner = Trove.new()
    }, Constant)

    return self
end

function Constant:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            Constant.StaticDraw(Players.LocalPlayer, gunModel.Barrel.Position, target, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Constant.StaticDraw(player: Player, startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    local startTick = tick()
    local bulletInfo = getConstantBullets(player, bulletCache, startTick)
    local bullet = bulletInfo.Bullet1 :: BasePart
    local bullet2 = bulletInfo.Bullet2 :: BasePart
    
    local iDist = (endPosition - startPosition).Magnitude
    
    local oldBulletScale = bullet.Mesh.Scale
    bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    local oldBulletCFrame = bullet.CFrame
    bullet.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    
    local x = bullet.Mesh.Scale.X
    local y = bullet.Mesh.Scale.Y
    local z = bullet.Mesh.Scale.Z
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

    task.delay(.1, function()
        if bulletInfo.Tick == startTick then
            bullet.Mesh.Scale = oldBulletScale
            bullet.CFrame = oldBulletCFrame
            bulletCache:ReturnPart(bullet)
            bullet2.Mesh.Scale = oldBulletScale
            bullet2.Mesh.Offset = oldBullet2Offset
            bullet2.CFrame = oldBulletCFrame
            bulletCache:ReturnPart(bullet2)
            
            ACTIVE_BULLETS_TABLE[player] = nil
        end
    end)
end

function Constant:Destroy()
    self.Cleaner:Destroy()
end

return Constant
