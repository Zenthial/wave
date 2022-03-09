local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))
local PartCache = require(Shared:WaitForChild("util"):WaitForChild("PartCache"))

local Mouse = require(script.Parent.Parent.Parent.Parent.Components.Player.Mouse)
local ClientComm = require(script.Parent.Parent.Parent.ClientComm)

local Player = game.Players.LocalPlayer
local BulletFolder = workspace:WaitForChild("Bullets") :: Folder

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

        MouseComponent = Rosyn.GetComponent(Player, Mouse),

        Cleaner = Trove.new()
    }, Ray)
    return self
end

function Ray:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            local bullet = self.WeaponStats.BulletCache:GetPart() :: BasePart
            Ray.StaticDraw(gunModel.Barrel.Position, target, bullet, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Ray.StaticDraw(startPosition: Vector3, endPosition: Vector3, bullet: BasePart, bulletCache: PartCache.PartCache)
    CollectionService:AddTag(bullet, "Ignore")
    
    local iDist = (endPosition - startPosition).Magnitude
    
    bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    bullet.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    
    local x = bullet.Mesh.Scale.X
    local y = bullet.Mesh.Scale.Y
    local z = bullet.Mesh.Scale.Z
    local bullet2 = bulletCache:GetPart()
    local scale = z * .5
    local offset = -z * .25
    if z > 100 then
        scale = z - 50
        offset = -50
    end
    bullet2.Mesh.Scale = Vector3.new(x, y, scale)
    bullet2.Mesh.Offset = Vector3.new(0, 0, offset)
    
    task.delay(.05, function()
        bulletCache:ReturnPart(bullet)
    end)

    task.delay(.1, function()
        bulletCache:ReturnPart(bullet2)
    end)
end

function Ray:Destroy()
    self.Cleaner:Destroy()
end

return Ray