-- tom
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local CoreGun = require(script.CoreGun)
local BulletModules = script.BulletModules

local ClientComm = require(script.Parent.ClientComm)

type WeaponStats = WeaponStatsModule.WeaponStats

export type Gun = {
    WeaponStats: WeaponStats
}

local Cleaner = Trove.new()
local KeyboardInput = Input.Keyboard.new()

local GunEngine = {}

function GunEngine:Start()
    local requiredBulletModules = {}

    for _, v in pairs(BulletModules:GetChildren()) do
        requiredBulletModules[v.Name] = require(v)    
    end

    local comm = ClientComm.GetClientComm() :: ClientComm.ClientComm
    local raySignal = comm:GetSignal("DrawRay")

    raySignal:Connect(function(startPosition: Vector3, endPosition: Vector3, weaponName: string)
        local weaponStats = WeaponStatsModule[weaponName]

        if weaponStats then
            local mod = requiredBulletModules[weaponStats.BulletType]
            if mod then
                mod.StaticDraw(startPosition, endPosition, weaponStats.BulletModel:Clone())
            end
        else
            error("WeaponStats don't exist??")
        end
    end)
end

function GunEngine:CreateGun(weaponStats: WeaponStats): Gun
    return CoreGun.new(weaponStats)
end

return GunEngine