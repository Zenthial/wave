local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local PartCache = require(Shared:WaitForChild("util"):WaitForChild("PartCache"))

-- little functional monad
-- obviously isn't pure cause it errors, but it could be made to not error
local function errorWrapper(func: () -> () | nil): (Player, Vector3, Vector3, PartCache.PartCache) -> ()
    if func == nil then error("No function found") end

    return func
end

local BulletRenderer = {}

function BulletRenderer.GetDrawFunction(bulletType: string)
    return errorWrapper(BulletRenderer["Draw"..bulletType])
end

function BulletRenderer.DrawRay(player: Player, startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    local bullet = bulletCache:GetPart() :: BasePart
    CollectionService:AddTag(bullet, "Ignore")
    
    local iDist = (endPosition - startPosition).Magnitude

    -- local bulletHolder = Instance.new("Model")
        
    -- local P = Instance.new("Part")
    -- P.Size = Vector3.new(.1, .1, iDist)
    -- P.Transparency = .5
    -- P.Anchored = true
    -- P.CanCollide = false
    -- P.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0,0, iDist/-2)
    -- P.Material = Enum.Material.Neon
    -- P.BrickColor = BrickColor.new("Pearl")
    
    -- local P2 = P:Clone()
    -- P2.BrickColor = BrickColor.new("Bright blue")
    -- P2.Material = Enum.Material.Neon
    -- P2.Transparency = .5
    -- P2.Size = Vector3.new(.2, .2, iDist)
    -- P2.CFrame = P.CFrame
    -- P2.Parent = bulletHolder
    
    -- CollectionService:AddTag(P, "Ignore")
    -- CollectionService:AddTag(P2, "Ignore")
    -- P.Parent = bulletHolder
    
    -- bulletHolder.Parent = workspace
    -- game.Debris:AddItem(bulletHolder,.04)

    local oldBulletScale = bullet.Mesh.Scale
    bullet.Mesh.Scale = Vector3.new(bullet.Mesh.Scale.X, bullet.Mesh.Scale.Y, iDist)
    local oldBulletCFrame = bullet.CFrame
    bullet.CFrame = CFrame.new(startPosition, endPosition) * CFrame.new(0, 0, -iDist / 2)
    local oldBulletColor = bullet.BrickColor
    
    bullet.BrickColor = BrickColor.new("Pearl")
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
    bullet2.Mesh.Scale = Vector3.new(x + .2, y + .2, scale)
    bullet2.Mesh.Offset = Vector3.new(0, 0, offset)
    
    task.delay(.05, function()
        bullet.Mesh.Scale = oldBulletScale
        bullet.CFrame = oldBulletCFrame
        bullet.BrickColor = oldBulletColor
        bulletCache:ReturnPart(bullet)
    end)

    task.delay(.1, function()
        bullet2.Mesh.Scale = oldBulletScale
        bullet2.Mesh.Offset = oldBullet2Offset
        bullet2.CFrame = oldBulletCFrame
        bulletCache:ReturnPart(bullet2)
    end)
end

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

function BulletRenderer.DrawConstant(player: Player, startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
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

function BulletRenderer.DrawStreak(_player: Player, startPosition: Vector3, endPosition: Vector3, bulletCache: PartCache.PartCache)
    math.randomseed(tick())
    
    local maxSegments = 5	
    local raySpread = 1
    local raySpeed = .02
    local lengthFactor = .01
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

return BulletRenderer