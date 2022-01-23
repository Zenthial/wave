local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

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

function Ray.new(gunModel: GunModel, weaponStats)
    local self = setmetatable({
        Model = gunModel,
        WeaponStats = weaponStats,

        MouseComponent = Rosyn.GetComponent(Player, Mouse),

        Cleaner = Trove.new()
    }, Ray)
    return self
end

function Ray:Draw(target: Vector3): boolean
    if self.Model ~= nil then
        local gunModel = self.Model :: GunModel
        if gunModel.Barrel ~= nil then            
            local bullet = self.WeaponStats.BulletModel:Clone() :: BasePart
            Ray.StaticDraw(gunModel.Barrel.Position, target)

            return true
        end
    end

    return false
end

function Ray.StaticDraw(startPosition: Vector3, endPosition: Vector3, bullet: BasePart)
    CollectionService:AddTag(bullet, "Ignore")
    
    local iDist = (endPosition - startPosition).Magnitude
    
    bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    bullet.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    
    local x = bullet.Mesh.Scale.X
    local y = bullet.Mesh.Scale.Y
    local z = bullet.Mesh.Scale.Z
    local bullet2 = bullet:Clone()
    local scale = z * .5
    local offset = -z * .25
    if z > 100 then
        scale = z - 50
        offset = -50
    end
    bullet2.Mesh.Scale = Vector3.new(x, y, scale)
    bullet2.Mesh.Offset = Vector3.new(0, 0, offset)
    
    Debris:AddItem(bullet, .05)
    Debris:AddItem(bullet2, .10)

    bullet.Parent = BulletFolder
    bullet2.Parent = BulletFolder
end

function Ray:Destroy()
    self.Cleaner:Destroy()
end

return Ray