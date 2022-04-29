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

local Streak = {}
Streak.__index = Streak
Streak.__Tag = "Streak"

function Streak.new(gunModel: GunModel, weaponStats)
    local self = setmetatable({
        GunModel = gunModel,
        WeaponStats = weaponStats,

        Cleaner = Trove.new()
    }, Streak)
    return self
end

function Streak:Draw(target: Vector3): boolean
    if self.GunModel ~= nil then
        local gunModel = self.GunModel :: GunModel
        if gunModel.Barrel ~= nil then            
            Streak.StaticDraw(gunModel.Barrel.Position, target, self.WeaponStats.BulletCache)

            return true
        end
    end

    return false
end

function Streak.StaticDraw(startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    math.randomseed(tick())
    
    local maxSegments = 5	
    local raySpread = 1
    local raySpeed = .02
    local lengthFactor = .01
    local segments = {}	
    local dist = (startPosition - endPosition).Magnitude
    local numSegments = maxSegments
    
    -- if detailed rays of then numSegments = 3

    local lastPoint = startPosition
    local originalCFrame = CFrame.new(startPosition, endPosition)
    
    for i = 1, numSegments do
        task.delay(raySpeed * i, function()
            local segment = bulletCache:GetPart() :: BasePart	

            local currentDistance = dist * i/numSegments
            local newPoint = originalCFrame * CFrame.new(0, 0, -(currentDistance))
            
            ---@diagnostic disable-next-line: redefined-local
            local raySpread = raySpread + (currentDistance * lengthFactor)
            newPoint = newPoint.Position + Vector3.new(math.random(-raySpread, raySpread), math.random(-raySpread, raySpread), math.random(-raySpread, raySpread))
            
            local oldScale = segment.Mesh.Scale
            local oldCFrame = segment.CFrame
            
            if i == numSegments then
                local pointDistance = (lastPoint - endPosition).Magnitude
                segment.Mesh.Scale = Vector3.new(segment.Mesh.Scale.X, segment.Mesh.Scale.Y, pointDistance)
                segment.CFrame = CFrame.new(lastPoint, endPosition) * CFrame.new(0, 0, -pointDistance/2)
            else
                local pointDistance = (lastPoint - newPoint).Magnitude
                segment.Mesh.Scale = Vector3.new(segment.Mesh.Scale.X, segment.Mesh.Scale.Y, pointDistance)
                segment.CFrame = CFrame.new(lastPoint, newPoint) * CFrame.new(0, 0, -pointDistance/2)

                lastPoint = newPoint
            end
            
            task.delay(raySpeed * i, function()
                segment.Mesh.Scale = oldScale
                segment.CFrame = oldCFrame
                bulletCache:ReturnPart(segment)
            end)
        end)
    end	
end

function Streak:Destroy()
    self.Cleaner:Destroy()
end

return Streak