-- tom
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local SkillStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("SkillStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local CoreGun = require(script.CoreGun)
local CoreSkill = require(script.Skills.CoreSkill)
local BulletModules = script.BulletModules

local ClientComm = require(script.Parent.ClientComm)

type WeaponStats = WeaponStatsModule.WeaponStats

export type Gun = {
    WeaponStats: WeaponStats
}

local Cleaner = Trove.new()
local KeyboardInput = Input.Keyboard.new()
local MouseInput = Input.Mouse.new()

local GunEngine = {}

function GunEngine:Start()
    local requiredBulletModules = {}

    for _, v in pairs(BulletModules:GetChildren()) do
        requiredBulletModules[v.Name] = require(v)    
    end

    local comm = ClientComm.GetClientComm()
    local raySignal = comm:GetSignal("DrawRay")

    Cleaner:Add(raySignal:Connect(function(startPosition: Vector3, endPosition: Vector3, weaponName: string)
        local weaponStats = WeaponStatsModule[weaponName]

        if weaponStats then
            local mod = requiredBulletModules[weaponStats.BulletType]
            if mod then
                mod.StaticDraw(startPosition, endPosition, weaponStats.BulletCache:GetPart(), weaponStats.BulletCache)
            end
        else
            error("WeaponStats don't exist??")
        end
    end))

    Cleaner:Add(MouseInput.LeftDown:Connect(function()
        
    end))
end

function GunEngine:CreateGun(weaponName: string, model): Gun
    local stats = WeaponStatsModule[weaponName]
    assert(stats, "No weapon stats for ".. weaponName)
    return CoreGun.new(stats, model)
end

function GunEngine:CreateSkill(skillName: string, model)
    local stats = SkillStatsModule[skillName]
    assert(stats, "No skill stats for ".. skillName)
    return CoreSkill.new(stats, model)
end

return GunEngine