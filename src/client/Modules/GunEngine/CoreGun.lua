local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Stats"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local AttackModules = script.Parent.AttackModules
local AmmoModules = script.Parent.AmmoModules

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

local function getAttackModule(stats: WeaponStats, gunType: string, model: GunModel): table
    if gunType == "Auto" then
        return require(AttackModules.Auto).new(stats, model)
    end
end

local function getAmmoModule(stats: WeaponStats, ammoType: string, shotsTable: ShotsTable): table
    if ammoType == "Battery" then
        return require(AmmoModules.Battery).new(stats.HeatRate, stats.CoolTime, stats.CoolWait, shotsTable)
    end
end

local CoreGun = {}
CoreGun.__index = CoreGun

function CoreGun.new(weaponStats: WeaponStats, gunModel: GunModel)
    local storedShots: ShotsTable = {
        NumShots = 0,
        HitShots = 0,
        Headshots = 0,
        LastShot = nil :: LastShotData
    }

    local ammoModule = getAmmoModule(weaponStats, weaponStats.AmmoType, storedShots)
    local attackModule = getAttackModule(weaponStats, weaponStats.GunType, gunModel)

    local cleaner = Trove.new();

    cleaner:Add(ammoModule.Events.Reloading:Connect(function(bool: boolean)
        attackModule:CanFire(bool)
    end))

    cleaner:Add(attackModule.Events.Attacked:Connect(function()
        ammoModule:Fire()
    end))
    
    return setmetatable({
        Model = gunModel,

        WeaponStats = weaponStats,
        StoredShots = storedShots,
        
        AttackModule = attackModule,
        AmmoModule = ammoModule,

        Cleaner = cleaner,
    }, CoreGun)
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