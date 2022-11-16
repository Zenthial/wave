local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local radiusDamage = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("radiusDamage"))
local radiusRaycast = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("radiusRaycast"))

local courier = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("courier"))

local LocalPlayer = Players.LocalPlayer

local function getGrenade(partCache, cframe)
    local grenade = partCache:GetPart()
    grenade.Anchored = false
    grenade.CanCollide = true
    grenade.CanTouch = false
    grenade.CanQuery = false
    grenade.CFrame = cframe

    return grenade
end

local function makeExplosion(grenade, stats)
    local explosion = Instance.new("Explosion")
    explosion.Position = grenade.Position
    explosion.BlastRadius = stats.NadeRadius
    explosion.BlastPressure = 0
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = workspace

    grenade.Explode:Play()

    return explosion
end

local GadgetFunctions = {}

function GadgetFunctions.NDG(partCache, cframe: CFrame, sourceTeam: BrickColor, sourcePlayer: Player, stats)
    task.spawn(function()
        if stats.Exploding == true then return end
        stats.Exploding = true
        local grenade = getGrenade(partCache, cframe)
        
        task.wait(stats.PopTime)
        local explosion = makeExplosion(grenade, stats)

        task.delay(1, function()
            explosion:Destroy()
        end)

        if sourcePlayer ~= LocalPlayer then
            radiusDamage(stats, cframe.Position, nil, false)
        end
        task.wait(stats.DelayTime)
        partCache:ReturnPart(grenade)
        stats.Exploding = false
    end)
end

function GadgetFunctions.H3G(partCache, cframe: CFrame, sourceTeam: BrickColor, sourcePlayer: Player, stats)
    task.spawn(function()
        if stats.Exploding == true then return end
        stats.Exploding = true
        local grenade = getGrenade(partCache, cframe)
        
        task.wait(stats.PopTime)
        local explosion = grenade.ParticleEmitter2
        local explosion1 = grenade.ParticleEmitter1
        explosion:Emit(30)
        explosion1.Enabled = false
        explosion1:Clear()
        grenade.Transparency = 1
        grenade.Explode:Play()

        local character = sourcePlayer.Character or sourcePlayer.CharacterAdded:Wait()
        local isNear = radiusRaycast(character.HumanoidRootPart.Position, 10, function(player)
            return player == LocalPlayer and player ~= sourcePlayer
        end)

        if #isNear > 0 then
            courier:Send("H3GRequest")
        end
        task.wait(stats.DelayTime)
        explosion.Enabled = false
        explosion:Clear()
        explosion1.Enabled = true
        grenade.Transparency = 0
        partCache:ReturnPart(grenade)
        stats.Exploding = false
    end)
end

function GadgetFunctions.STK(partCache, cframe: CFrame, sourceTeam: BrickColor, sourcePlayer: Player, stats, lastHitPart: Part, lastHitPoint: Vector3)
    task.spawn(function()
        if stats.Exploding == true then return end
        stats.Exploding = true
        local grenade = getGrenade(partCache, cframe)

        local weld = Instance.new("WeldConstraint")
        if lastHitPoint and lastHitPart then
            grenade.Position = lastHitPoint
            weld.Part0 = lastHitPart
            weld.Part1 = grenade
            weld.Parent = lastHitPart

            if LocalPlayer == sourcePlayer then
                -- SANITY CHECK HERE TO MAKE SURE EVERYONE WELDS TO THE SAME POINT
            end
        end

        task.wait(stats.PopTime)
        local explosion = makeExplosion(grenade, stats)

        task.delay(1, function()
            explosion:Destroy()
        end)

        if sourcePlayer ~= LocalPlayer then
            radiusDamage(stats, cframe.Position, nil, false)
        end
        task.wait(stats.DelayTime)
        weld:Destroy()
        partCache:ReturnPart(grenade)
        stats.Exploding = false
    end)
end

function GadgetFunctions.C0S(partCache, cframe: CFrame, sourceTeam: BrickColor, sourcePlayer: Player, stats)
    task.spawn(function()
        if stats.Exploding == true then return end
        stats.Exploding = true
        local grenade = getGrenade(partCache, cframe)

        grenade.BrickColor = sourceTeam
        local startCFrame = grenade.CFrame
        local tween = TweenService:Create(grenade, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = Vector3.new(stats.Size, stats.Size, stats.Size)})
        tween:Play()
        tween.Completed:Wait()

        grenade.CFrame = startCFrame
        grenade.Transparency = 0.5

        grenade.Buzzing:Play()
        -- this should be moved somewhere
        -- reminder, implement a
        -- implement a what tom??
        local active = true
        task.spawn(function()
            while active and sourcePlayer ~= LocalPlayer do
                radiusDamage(stats, cframe.Position, nil, false)
                task.wait(0.05)
            end
        end)

        if stats.DecreaseSize then
            local info = TweenInfo.new(stats.DelayTime + .5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
            local sizeDecrease = TweenService:Create(grenade, info, {Size = Vector3.new(0, 0, 0)})
            sizeDecrease:Play()
            sizeDecrease.Completed:Wait()
        else
            task.wait(stats.DelayTime - .1)
            local sizeDecrease = TweenService:Create(grenade, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, 0)})
            sizeDecrease:Play()
        end

        grenade.Buzzing:Stop()
        active = false
        partCache:ReturnPart(grenade)
        stats.Exploding = false
    end)
end

return GadgetFunctions