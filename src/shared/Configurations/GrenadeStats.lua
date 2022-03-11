local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PartCache = require(ReplicatedStorage.Shared.util.PartCache)

export type GrenadeStats_T = {
    DEBUG: boolean,

    ProjectileSpeed: number,
    MaxDistance: number,

    NadeRadius: number,
    MaxDamage: number,

    Bounce: boolean,
    NumBounces: number,

    PopTime: number,
    DelayTime: number,

    Gravity: Vector3,

    MinSpreadAngle: number,
    MaxSpreadAngle: number,

    Cache: typeof(PartCache),
}

return {
    ["NDG"] = {
        DEBUG = false,

        ProjectileSpeed = 110,
        MaxDistance = 1000,

        NadeRadius = 20,
        MaxDamage = 50,

        Bounce = true,
        NumBounces = 2,

        PopTime = 0.6,
        DelayTime = 0.1,

        Gravity = Vector3.new(0, -workspace.Gravity, 0),

        MinSpreadAngle = 0,
        MaxSpreadAngle = 0,
    }
}