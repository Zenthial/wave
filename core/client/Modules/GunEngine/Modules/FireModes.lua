local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local BulletRenderer = require(script.Parent.BulletRenderer)
local raycast = require(script.Parent.RaycastFunctions)

local Player = Players.LocalPlayer

local FireModes = {}

-- little functional monad
-- obviously isn't pure cause it errors, but it could be made to not error
local function errorWrapper(func: () -> () | nil): ({}, {}, Model, (Instance, {}, {}) -> ()) -> ()
    if func == nil then error("No function found") end

    return func
end

function FireModes.GetFireMode(fireMode: string)
    return errorWrapper(FireModes[fireMode])
end

function FireModes.RaycastAndDraw(mouse, weaponStats, mutableStats, gunModel: Model, checkHitPart: (Instance, {}, {}) -> ())
    task.spawn(function()
        if gunModel ~= nil and gunModel.Barrel ~= nil then         
            local hit, target = raycast(weaponStats)
            
            if hit ~= nil and weaponStats.FireMode ~= "Launcher" then
                task.spawn(checkHitPart, hit, weaponStats, mouse)
            end

            mutableStats.ShotsTable.LastShot.StartPosition = gunModel.Barrel.Position
            mutableStats.ShotsTable.LastShot.EndPosition = target
            mutableStats.ShotsTable.LastShot.Timestamp = tick()
            mutableStats.ShotsTable.NumShots += 1
            BulletRenderer.GetDrawFunction(weaponStats.BulletType)(Player, gunModel.Barrel.Position, target, weaponStats.BulletCache)
        end
    end)
end

function FireModes.Auto(weaponStats, mutableStats, gunModel: Model, checkHitPart: (Instance, {}, {}) -> ())
    local mouse = tcs.get_component(Player, "Mouse")

    if not mutableStats.Shooting then
        -- make it a do while because of weird edge cases in function calling
        repeat
            mutableStats.Shooting = true
    
            FireModes.RaycastAndDraw(mouse, weaponStats, mutableStats, gunModel, checkHitPart)
    
            task.wait(1/weaponStats.FireRate)
        until mutableStats.MouseDown == false or not mutableStats.CanShoot

        mutableStats.Shooting = false
    end
end

function FireModes.Semi(weaponStats, mutableStats, gunModel: Model, checkHitPart: (Instance, {}, {}) -> ())
    local mouse = tcs.get_component(Player, "Mouse")

    if not mutableStats.Shooting then
        -- make it a do while because of weird edge cases in function calling
        mutableStats.Shooting = true
    
        FireModes.RaycastAndDraw(mouse, weaponStats, mutableStats, gunModel, checkHitPart)

        task.wait(1/weaponStats.FireRate)
        mutableStats.Shooting = false
    end
end


return FireModes