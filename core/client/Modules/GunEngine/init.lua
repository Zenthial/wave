-- tom
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local bluejay = require(Shared:WaitForChild("bluejay"))
local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local SkillStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("SkillStats"))
local GadgetStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local CoreGun = require(script.CoreGun)
local CoreSkill = require(script.Skills.CoreSkill)
local Grenades = require(script.Grenades)
local BulletModules = script.BulletModules

local ClientComm = require(script.Parent.ClientComm)
local comm = ClientComm.GetClientComm()

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

type WeaponStats = {}

export type Gun = {
    WeaponStats: WeaponStats
}

local Cleaner = Trove.new()
local KeyboardInput = Input.Keyboard.new()
local MouseInput = Input.Mouse.new()

local GunEngine = {}

function GunEngine:Start()
    if Player.Character == nil then
        Player.CharacterAdded:Wait()
    end
    local requiredBulletModules = {}

    for _, v in pairs(BulletModules:GetChildren()) do
        requiredBulletModules[v.Name] = require(v)    
    end

    local raySignal = comm:GetSignal("DrawRay")
    local nadeSignal = comm:GetSignal("RenderGrenade")

    Cleaner:Add(raySignal:Connect(function(startPosition: Vector3, endPosition: Vector3, weaponName: string)
        local weaponStats = WeaponStatsModule[weaponName]

        if weaponStats then
            local mod = requiredBulletModules[weaponStats.BulletType]
            if mod then
                mod.StaticDraw(startPosition, endPosition, weaponStats.BulletCache)
            end
        else
            error("WeaponStats don't exist??")
        end
    end))

    Cleaner:Add(MouseInput.LeftDown:Connect(function()
        
    end))

    Cleaner:Add(nadeSignal:Connect(function(player: Player, position: Vector3, direction: Vector3, movementSpeed: number, grenade: string)
        self:RenderGrenadeForOtherPlayer(player, position, direction, movementSpeed, grenade)
    end))
end

function GunEngine:RenderGrenadeForLocalPlayer(grenadeName: string)
    local hrp = Player.Character.HumanoidRootPart
    local leftArm = Player.Character["Left Arm"] :: Part

    local GadgetStats = GadgetStatsModule[grenadeName]
    assert(GadgetStats, "No grenade stats for the grenade")
    
    if Player.Character ~= nil and leftArm ~= nil and Mouse.UnitRay.Direction ~= nil and hrp ~= nil and Player:GetAttribute("LocalSprinting") == false then
        Player:SetAttribute("Throwing", true)
        
        local nadeSignal = comm:GetSignal("RenderGrenade")
        nadeSignal:Fire(leftArm.Position, Mouse.UnitRay.Direction, hrp.AssemblyLinearVelocity, grenadeName)
        Grenades:RenderNade(Player, leftArm.Position, Mouse.UnitRay.Direction, hrp.AssemblyLinearVelocity, GadgetStats)
    end
end

function GunEngine:RenderGrenadeForOtherPlayer(player: Player, position: Vector3, direction: Vector3, movementSpeed: Vector3, grenade: string)
    local stats = GadgetStatsModule[grenade]
    assert(stats ~= nil, "No gadget stats for "..grenade)
    Grenades:RenderNade(player, position, direction, movementSpeed, stats)
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