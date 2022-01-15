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

local function getAttackModule(stats: WeaponStats, gunType: string): table
    if gunType == "Auto" then
        return require(AttackModules.Auto).new(stats)
    end
end

local function getAmmoModule(stats: WeaponStats, ammoType: string, shotsTable: ShotsTable): table
    if ammoType == "Battery" then
        return require(AmmoModules.Battery).new(stats.HeatRate, stats.CoolTime, stats.CoolWait, shotsTable)
    end
end

local CoreGun = {}
CoreGun.__index = CoreGun

function CoreGun.new(weaponStats: WeaponStats)
    local storedShots: ShotsTable = {
        NumShots = 0,
        HitShots = 0,
        Headshots = 0,
        LastShot = nil :: LastShotData
    }

    local ammoModule = getAmmoModule(weaponStats, weaponStats.AmmoType, storedShots)
    local attackModule = getAttackModule(weaponStats, weaponStats.GunType)
    
    return setmetatable({
        WeaponStats = weaponStats,
        StoredShots = storedShots,
        
        AttackModule = attackModule,

        Cleaner = Trove.new(),
    }, CoreGun)
end

function CoreGun:Attack()
    self.AttackModule:Attack()
end

function CoreGun:Destroy()
    self.Cleaner:Destroy()
end

return CoreGun