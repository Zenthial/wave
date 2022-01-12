local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Stats"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

type WeaponStats = WeaponStatsModule.WeaponStats

local CoreGun = {}
CoreGun.__index = CoreGun

function CoreGun.new(weaponStats: WeaponStats)
    return setmetatable({
        WeaponStats = weaponStats,
        
        Cleaner = Trove.new(),
    }, CoreGun)
end

function CoreGun:Destroy()
    
end

return CoreGun