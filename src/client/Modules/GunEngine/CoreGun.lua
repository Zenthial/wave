local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local Rosyn = require(Shared:WaitForChild("Rosyn"))

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Signal = require(Shared:WaitForChild("util", 5):WaitForChild("Signal", 5))

local AnimationTree = require(script.Parent.Parent.Parent.Components.AnimationTree)
local Animator = require(script.Parent.Parent.Parent.Components.Animation)

local ClientComm = require(script.Parent.Parent.ClientComm)
local comm = ClientComm.GetClientComm()

local Player = Players.LocalPlayer

local AttackModules = script.Parent.AttackModules
local AmmoModules = script.Parent.AmmoModules
local BulletModules = script.Parent.BulletModules

type WeaponStats = WeaponStatsModule.WeaponStats
type LastShotData = {
    StartPosition: Vector3,
    EndPosition: Vector3,
    Timestamp: number,
}
type ShotsTable = {
    NumShots: number,
    HitShots: number,
    Headshots: number,
    LastShot: LastShotData
}
type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

-- this block needs to be improved

local LoadedModules = {
    Attack = {},
    Ammo = {},
    Bullet = {}
}

local function loadModulesOfType(tble, folder)
    for _, v in pairs(folder:GetChildren()) do
        tble[v.Name] = require(v)
    end
end

loadModulesOfType(LoadedModules.Attack, AttackModules)
loadModulesOfType(LoadedModules.Ammo, AmmoModules)
loadModulesOfType(LoadedModules.Bullet, BulletModules)

local function getAttackModule(stats: WeaponStats, bulletModule: table, gunModel, mutableStats, storedShots: ShotsTable): table
    local mod = LoadedModules.Attack[stats.GunType]
    if mod then
        return mod.new(stats, bulletModule, gunModel, mutableStats, storedShots)
    end
end

local function getAmmoModule(stats: WeaponStats, shotsTable: ShotsTable): table
    local mod = LoadedModules.Ammo[stats.AmmoType]
    if mod then
        return mod.new(stats.HeatRate, stats.CoolTime, stats.CoolWait, stats.BatteryDepletionMin, stats.BatteryDepletionMax, stats.ShotsDeplete, shotsTable)
    end
end

local function getBulletModule(gunModel: GunModel, stats: WeaponStats)
    local mod = LoadedModules.Bullet[stats.BulletType]
    if mod then
        return mod.new(gunModel, stats)
    end
end

local function recursivelyFindHealthComponent(part: BasePart)
    if CollectionService:HasTag(part, "Health") then
        return part
    elseif part.Parent ~= workspace then
        return recursivelyFindHealthComponent(part.Parent)
    else
        return nil
    end
end

local CoreGun = {}
CoreGun.__index = CoreGun
CoreGun.__Tag = "CoreGun"

function CoreGun.new(weaponStats: WeaponStats, gunModel: GunModel)
    local storedShots: ShotsTable = {
        NumShots = 0,
        HitShots = 0,
        Headshots = 0,
        LastShot = {
            StartPosition = nil,
            EndPosition = nil,
            Timestamp = tick()
        } :: LastShotData
    }

    local mutableStats = {
        AimBuff = 3,
        CurrentRecoil = 0,

        Equipped = false,
        Aiming = false,
        MouseDown = false,
    }

    local bulletModule = getBulletModule(gunModel, weaponStats)
    local ammoModule = getAmmoModule(weaponStats, storedShots)
    local attackModule = getAttackModule(weaponStats, bulletModule, gunModel, mutableStats, storedShots)
    
    local weldWeaponFunction = comm:GetFunction("WeldWeapon") :: (BasePart, boolean) -> boolean
    local attemptDealDamageFunction = comm:GetFunction("AttemptDealDamage") :: (BasePart, string) -> boolean

    local character = Player.Character or Player.CharacterAdded:Wait()
    local animationTreeComponent = Rosyn.AwaitComponentInit(character, AnimationTree) :: typeof(AnimationTree)
    local animationComponent = Rosyn.AwaitComponentInit(character, Animator) :: typeof(Animator)

    for _, animationData in pairs(weaponStats.Animations) do
        animationComponent:Load(animationData)
    end

    local ammoChanged = Signal.new()
    local fired = Signal.new()

    local cleaner = Trove.new();
    cleaner:Add(ammoModule.Events.Reloading:Connect(function(bool: boolean)
        attackModule:SetCanFire(bool)

        animationTreeComponent:SetReload(bool)
    end))

    cleaner:Add(ammoModule.Events.AmmoChanged:Connect(function(ammo): boolean
        ammoChanged:Fire(ammo)
    end))

    cleaner:Add(attackModule.Events.Attacked:Connect(function()
        ammoModule:Fire()
    end))

    cleaner:Add(attackModule.Events.StoppedShooting:Connect(function()
        fired:Fire(1/weaponStats.FireRate)
    end))

    cleaner:Add(attackModule.Events.CheckHitPart:Connect(function(hitPart)
        local healthComponentPart = recursivelyFindHealthComponent(hitPart)
        if healthComponentPart ~= nil then
            attemptDealDamageFunction(healthComponentPart, weaponStats.Name)
        end
    end))

    return setmetatable({
        Model = gunModel,

        WeaponStats = weaponStats,
        StoredShots = storedShots,
        MutableStats = mutableStats,
        
        AttackModule = attackModule,
        AmmoModule = ammoModule,
        BulletModule = bulletModule,

        WeldWeaponFunction = weldWeaponFunction,

        AnimationTree = animationTreeComponent,

        Events = {
            AmmoChanged = ammoChanged,
            Fired = fired
        },

        Cleaner = cleaner,
    }, CoreGun)
end

function CoreGun:Equip()
    self.AnimationTree:EquipWeapon(self)
    local result = self.WeldWeaponFunction(self.Model, false) :: boolean
    if result == false then
        error("Weld failed, does this weapon have stats?")
    end
    self.MutableStats.Equipped = true
end

function CoreGun:Unequip()
    self.AnimationTree:UnequipWeapon()
    local result = self.WeldWeaponFunction(self.Model, true) :: boolean
    if result == false then
        error("Weld failed, does this weapon have stats?")
    end
    self.MutableStats.Equipped = false
end

function CoreGun:MouseDown()
    self.MutableStats.MouseDown = true
    self:Attack()
end

function CoreGun:MouseUp()
    self.MutableStats.MouseDown = false
end

function CoreGun:Attack()
    if self.AmmoModule:CanFire() then
        self.AttackModule:Attack()
    end
end

function CoreGun:Reload()
    if self.WeaponStats.AmmoType ~= "Battery" then
        self.AmmoModule:Reload()
    end
end

function CoreGun:Destroy()
    self.Cleaner:Destroy()
end

return CoreGun