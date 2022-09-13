local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tcs = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))

local GadgetStats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("GadgetStats"))

local Grenades = require(script.Parent.Parent.Grenades)
local BulletRenderer = require(script.Parent.BulletRenderer)
local raycast = require(script.Parent.RaycastFunctions)

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local CursorUI = PlayerGui:WaitForChild("Cursor"):WaitForChild("Cursor")
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()

local FireModes = {}

-- little functional monad
-- obviously isn't pure cause it errors, but it could be made to not error
local function errorWrapper(func: () -> () | nil): ({}, {}, Model, (Instance, {}, {}) -> ()) -> ()
    if func == nil then error("No function found") end

    return func
end

local function changeBarrel(weaponStats, mutableStats)
    if mutableStats.CurrentBarrel ~= weaponStats.NumBarrels then
        mutableStats.CurrentBarrel += 1
    else
        mutableStats.CurrentBarrel = 1
    end
end

local function getBarrel(weaponStats, mutableStats, gunModel)
    if weaponStats.NumBarrels > 1 then
        local barrel = gunModel["Barrel"..mutableStats.CurrentBarrel]
        changeBarrel(weaponStats, mutableStats)
        return barrel
    end

    return gunModel.Barrel
end

function FireModes.GetFireMode(fireMode: string)
    return errorWrapper(FireModes[fireMode])
end

function FireModes.RaycastAndDraw(cursorUIComponent, weaponStats, mutableStats, gunModel: Model, checkHitPart: (Instance, {}, {}) -> ())
    task.spawn(function()
        local barrel = getBarrel(weaponStats, mutableStats, gunModel)
        if gunModel ~= nil and barrel ~= nil then         
            local hit, target = raycast(weaponStats, gunModel)
            
            if hit ~= nil and weaponStats.FireMode ~= "Launcher" then
                task.spawn(checkHitPart, hit, weaponStats, cursorUIComponent)
            end

            barrel.Fire:Play()
            mutableStats.ShotsTable.LastShot.StartPosition = barrel.Position
            mutableStats.ShotsTable.LastShot.EndPosition = target
            mutableStats.ShotsTable.LastShot.Timestamp = tick()
            mutableStats.ShotsTable.NumShots += 1
            BulletRenderer.GetDrawFunction(weaponStats.BulletType)(Player, barrel.Position, target, weaponStats.BulletCache)
        end
    end)
end

function FireModes.Auto(weaponStats, mutableStats, gunModel: Model, checkHitPart: (Instance, {}, {}) -> ())
    local cursorUIComponent = tcs.get_component(CursorUI, "Cursor")

    if not mutableStats.Shooting then
        -- make it a do while because of weird edge cases in function calling
        repeat
            mutableStats.Shooting = true
    
            FireModes.RaycastAndDraw(cursorUIComponent, weaponStats, mutableStats, gunModel, checkHitPart)
    
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

function FireModes.Launcher(weaponStats, mutableStats, gunModel: Model)
    local gadgetStats = GadgetStats[weaponStats.Name]
    assert(gadgetStats, "No gadget stats for "..weaponStats.Name)

    local hrp = Character:WaitForChild("HumanoidRootPart")
    mutableStats.Shooting = true
    Grenades:RenderNade(Player, gunModel.Barrel.Position, Mouse.UnitRay.Direction, hrp.AssemblyLinearVelocity, gadgetStats)
    task.wait(1/weaponStats.FireRate)
    mutableStats.Shooting = false
end

function FireModes.Rocket(weaponStats, mutableStats, gunModel)
    local gadgetStats = GadgetStats[weaponStats.Name]
    assert(gadgetStats, "No gadget stats for "..weaponStats.Name)

    local hrp = Character:WaitForChild("HumanoidRootPart")
    mutableStats.Shooting = true
    Grenades:RenderNade(Player, gunModel.Barrel.Position, gunModel.Barrel.CFrame.LookVector, hrp.AssemblyLinearVelocity, gadgetStats)
    task.wait(1/weaponStats.FireRate)
    mutableStats.Shooting = false
end

return FireModes