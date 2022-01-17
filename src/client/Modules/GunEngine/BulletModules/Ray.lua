local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared", 5)

local Rosyn = require(Shared:WaitForChild("Rosyn", 5))
local Trove = require(Shared:WaitForChild("util"):WaitForChild("Trove"))

local Mouse = require(script.Parent.Parent.Parent.Parent.Components.Player.Mouse)

local Player = game.Players.LocalPlayer
local BulletFolder = workspace:WaitForChild("Bullets") :: Folder

type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local Ray = {}
Ray.__index = Ray

function Ray.new(gunModel: GunModel, weaponStats, mutableStats)
    local self = setmetatable({
        Model = gunModel,
        WeaponStats = weaponStats,
        MutableStats = mutableStats,

        MouseComponent = Rosyn.AwaitComponentInit(Mouse, Player),

        Cleaner = Trove.new()
    }, Ray)
    return self
end

function Ray:Draw(): (boolean, BasePart?, Vector3?)
    if self.Model ~= nil then
        local gunModel = self.Model :: GunModel
        if gunModel.Barrel ~= nil then
            local mouseComponent = self.MouseComponent :: typeof(Mouse)
            local hit, target = mouseComponent:Raycast(gunModel.Barrel.Position, self.WeaponStats, self.MutableStats.Aiming, self.MutableStats.CurrentRecoil, self.MutableStats.AimBuff)

            local iDist = (target - gunModel.Barrel.Position).Magnitude

            local bullet = self.WeaponStats.BulletModel:Clone() :: BasePart
            CollectionService:AddTag(bullet, "Ignore")
            
            bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
			bullet.CFrame = CFrame.new(gunModel.Barrel.Position, target) * CFrame.new(0,0,-iDist / 2)
			
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
    end

    return false
end

function Ray:Destroy()
    self.Cleaner:Destroy()
end

return Ray