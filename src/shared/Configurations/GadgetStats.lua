local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HapticService = game:GetService("HapticService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Grenades = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Grenades")
local PartCache = require(ReplicatedStorage.Shared.util.PartCache)

local dealSelfDamage = nil
if RunService:IsClient() then
    local StarterPlayer = game:GetService("StarterPlayer")
    local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
    local ClientComm = require(StarterPlayerScripts.Client.Modules.ClientComm)
    local Comm = ClientComm.GetClientComm()
    dealSelfDamage = Comm:GetFunction("DealSelfDamage")
end

local cacheFolder = Instance.new("Folder")
cacheFolder.Name = "GrenadeCacheFolder"
cacheFolder.Parent = workspace

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

    Cache: typeof(PartCache),
    CacheFolder: Folder,

    TerminationBehavior: (BasePart, BrickColor, Player, GadgetStats_T) -> (), -- Should yield if pop-time is needed
}

return {
    ["NDG"] = {
        Name = "NDG",

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

        Cache = PartCache.new(Grenades.NDG.Projectile, 30, cacheFolder),
        CacheFolder = cacheFolder,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            grenade.Anchored = false
            grenade.CanCollide = true
            grenade.CanTouch = true
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

                local function Damage()
                    local distanceDamageFactor = 1-(distance/stats.NadeRadius)
                    dealSelfDamage(math.abs(stats.MaxDamage*distanceDamageFactor))
                end

                if distance <= stats.NadeRadius then
                    if sourcePlayer.TeamColor ~= sourceTeam then
                        Damage()
                    -- elseif Player == sourcePlayer then
                    --     Damage()
                    end
                end
            end
            task.wait(stats.DelayTime)
        end
    },

    ["C0S"] = {
        Name = "C0S",

        DEBUG = false,

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

        Cache = PartCache.new(Grenades.C0S.Projectile, 30, cacheFolder),
        CacheFolder = cacheFolder,

        -- this is intended to yield. this is called in a new thread, so we can yield. if we don't yield, the bullet/grenade will be cleaned up before we want it to be
        TerminationBehavior = function(grenade: BasePart, sourceTeam: BrickColor, sourcePlayer: Player, stats: GadgetStats_T)
            local function calcC0SDamage(damage, distance)
                return math.clamp(damage + (20 * (1 / distance)), 1, 15)
            end

            grenade.BrickColor = sourceTeam
            local startCFrame = grenade.CFrame
            local tween = TweenService:Create(grenade, TweenInfo.new(.1, Enum.EasingStyle.Linear), {Size = Vector3.new(stats.Size, stats.Size, stats.Size)})
            tween:Play()
            tween.Completed:Wait()

            grenade.CFrame = startCFrame
            grenade.Buzzing:Play()
            grenade.Transparency = 0.5

            -- this should be moved somewhere
            -- reminder, implement a
            local active = true
            task.spawn(function()
                while active do
                    local radius = grenade.Size.Magnitude / 2
                    local chr = sourcePlayer.Character
                    if chr ~= nil and chr.HumanoidRootPart ~= nil --[[ and sourcePlayer.TeamColor ~= sourceTeam]] then
                        local dist = (chr.HumanoidRootPart.Position - startCFrame.Position).Magnitude
                        if dist <= radius then
                            dealSelfDamage(calcC0SDamage(stats.MaxDamage, dist))
                        end
                    end
                    task.wait(0.05)
                end
            end)

            if stats.DecreaseSize then
                local info = TweenInfo.new(stats.DelayTime + .5, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
                local sizeDecrease = TweenService:Create(grenade, info, {Size = Vector3.new(0, 0, 0)})
                sizeDecrease:Play()
                sizeDecrease.Completed:Wait()
                grenade.Buzzing:Stop()
            else
                task.wait(stats.DelayTime - .1)
                local sizeDecrease = TweenService:Create(grenade, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = Vector3.new(0, 0, 0)})
                sizeDecrease:Play()
                sizeDecrease.Completed:Wait()
                grenade.Buzzing:Stop()
            end

            active = false
        end
    }
} :: {[string]: GadgetStats_T}