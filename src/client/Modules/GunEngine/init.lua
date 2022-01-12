-- tom
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local WeaponStatsModule = require(Shared:WaitForChild("Stats"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Input = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5))

local CoreGun = require(script.CoreGun)

type WeaponStats = WeaponStatsModule.WeaponStats

export type Gun = {
    WeaponStats: WeaponStats
}

local Cleaner = Trove.new()
local KeyboardInput = Input.Keyboard.new()

local GunEngine = {}

function GunEngine:CreateGun(weaponStats: WeaponStats): Gun
    return CoreGun.new(weaponStats)
end
