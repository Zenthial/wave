local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Gadgets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Gadgets")
local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local PartCache = require(ReplicatedStorage.Shared.util.PartCache)

local radiusDamage = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("functions"):WaitForChild("radiusDamage"))

export type GadgetStats_T = {
    Name: string,
    
    DEBUG: boolean,

    ProjectileSpeed: number,
    MaxDistance: number,

    NadeRadius: number,
    MaxDamage: number,

    Bounce: boolean,
    NumBounces: number,

    Size: number | nil,
    DecreaseSize: boolean | nil,

    PopTime: number,
    DelayTime: number,

    Gravity: Vector3,

    MinSpreadAngle: number,
    MaxSpreadAngle: number,

    CalculateDamage: (number, number) -> number,

    Cache: typeof(PartCache),
    CacheFolder: Folder,

    TerminationBehavior: (BasePart, BrickColor, Player, GadgetStats_T) -> (), -- Should yield if pop-time is needed
}

local CacheFolder = nil
local Caches = {
    NDG = nil,
    C0S = nil,
    PBW = nil,
}

if RunService:IsClient() then
    CacheFolder = Instance.new("Folder")
    CacheFolder.Name = "GrenadeCacheFolder"
    CacheFolder.Parent = workspace

    Caches.NDG = PartCache.new(Gadgets.NDG.Projectile, 30, CacheFolder)
    Caches.C0S = PartCache.new(Gadgets.C0S.Projectile, 30, CacheFolder)
    Caches.PBW = PartCache.new(Weapons.PBW.Projectile, 30, CacheFolder)
end

return {
    ["NDG"] = {
        Name = "NDG",
        Type = "Projectile",
        Quantity = 2,

        DEBUG = false,

        ProjectileSpeed = 150,
        MaxDistance = 1000,

        NadeRadius = 20,
        MaxDamage = 50,

        Bounce = false,
        NumBounces = 0,

        PopTime = 0.6,
        DelayTime = 0.1,

        Gravity = Vector3.new(0, -150, 0),

        MinSpreadAngle = 0,
        MaxSpreadAngle = 0,

        Cache = Caches.NDG,
        CacheFolder = CacheFolder,

        CalculateDamage = function(damage, dist)
            local distanceDamageFactor = 1-(dist/20)
            return math.abs(damage*distanceDamageFactor)
        end,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            grenade.Anchored = false
            grenade.CanCollide = true
            grenade.CanTouch = false
            grenade.CanQuery = false
            task.wait(stats.PopTime)
            local character = sourcePlayer.Character
            if character then
                local distance = (character.HumanoidRootPart.Position - grenade.Position).Magnitude
                local explosion = Instance.new("Explosion")
                explosion.Position = grenade.Position
                explosion.BlastRadius = stats.NadeRadius
                explosion.BlastPressure = 0
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = workspace

                task.delay(1, function()
                    explosion:Destroy()
                end)

                radiusDamage(stats, grenade, nil, false)
            end
            task.wait(stats.DelayTime)
        end
    },

    ["C0S"] = {
        Name = "C0S",
        Type = "Projectile",
        Quantity = 2,

        DEBUG = true,

        ProjectileSpeed = 150,
        MaxDistance = 1000,

        NadeRadius = -1,
        MaxDamage = -1,

        Bounce = false,
        NumBounces = 0,

        Size = 20,
        DecreaseSize = true,

        PopTime = 0,
        DelayTime = 5,

        Gravity = Vector3.new(0, -175, 0),

        MinSpreadAngle = 0,
        MaxSpreadAngle = 0,

        Cache = Caches.C0S,
        CacheFolder = CacheFolder,

        CalculateDamage = function(damage, distance)
            return math.clamp(damage + (20 * (1 / distance)), 1, 15)
        end,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            grenade.Anchored = true
            grenade.CanCollide = false
            grenade.CanTouch = false
            grenade.CanQuery = false

            grenade.BrickColor = sourceTeam
            local startCFrame = grenade.CFrame
            local tween = TweenService:Create(grenade, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = Vector3.new(stats.Size, stats.Size, stats.Size)})
            tween:Play()
            tween.Completed:Wait()

            grenade.CFrame = startCFrame
            grenade.Transparency = 0.5

            -- this should be moved somewhere
            -- reminder, implement a
            local active = true
            task.spawn(function()
                while active do
                    radiusDamage(stats, grenade, nil, false)
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

            active = false
        end
    },

    ["PBW"] = {
        Name = "PBW",
        Type = "Projectile",
        Quantity = 2,

        DEBUG = false,

        ProjectileSpeed = 200,
        MaxDistance = 1000,

        NadeRadius = 10,
        MaxDamage = 40,

        Bounce = false,
        NumBounces = 0,

        PopTime = 0,
        DelayTime = 0.3,

        Gravity = Vector3.new(0, -3, 0),

        MinSpreadAngle = 0,
        MaxSpreadAngle = 0,

        Cache = Caches.PBW,
        CacheFolder = CacheFolder,

        CalculateDamage = function(damage, dist)
            local distanceDamageFactor = 1-(dist/20)
            return math.abs(damage*distanceDamageFactor)
        end,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            grenade.Anchored = false
            grenade.CanCollide = true
            grenade.CanTouch = false
            grenade.CanQuery = false
            task.wait(stats.PopTime)
            local character = sourcePlayer.Character
            if character then
                local distance = (character.HumanoidRootPart.Position - grenade.Position).Magnitude
                grenade.ParticleEmitter1:Destroy()
				grenade.ParticleEmitter2.Enabled = true
                grenade.Explode:Play()
				grenade.Transparency = 1

                radiusDamage(stats, grenade, nil, false)
            end
            task.wait(stats.DelayTime)
            
        end
    },

    ["G25"] = {
        Name = "NDG",
        Type = "Projectile",
        Quantity = 2,

        DEBUG = false,

        ProjectileSpeed = 230,
        MaxDistance = 1000,

        NadeRadius = 20,
        MaxDamage = 50,

        Bounce = false,
        NumBounces = 0,

        PopTime = 0.6,
        DelayTime = 0.1,

        Gravity = Vector3.new(0, -200, 0),

        MinSpreadAngle = 0,
        MaxSpreadAngle = 0,

        Cache = Caches.NDG,
        CacheFolder = CacheFolder,

        CalculateDamage = function(damage, dist)
            local distanceDamageFactor = 1-(dist/20)
            return math.abs(damage*distanceDamageFactor)
        end,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            grenade.Anchored = false
            grenade.CanCollide = true
            grenade.CanTouch = false
            grenade.CanQuery = false
            task.wait(stats.PopTime)
            local character = sourcePlayer.Character
            if character then
                local distance = (character.HumanoidRootPart.Position - grenade.Position).Magnitude
                local explosion = Instance.new("Explosion")
                explosion.Position = grenade.Position
                explosion.BlastRadius = stats.NadeRadius
                explosion.BlastPressure = 0
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = workspace

                task.delay(1, function()
                    explosion:Destroy()
                end)

                radiusDamage(stats, grenade, nil, false)
            end
            task.wait(stats.DelayTime)
        end
    },
} :: {[string]: GadgetStats_T}
