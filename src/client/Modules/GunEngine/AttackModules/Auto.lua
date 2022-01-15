local WeaponStatsModule = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Stats"):WaitForChild("WeaponStats"))
local Trove = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Mouse = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input")).Mouse

type WeaponStats = WeaponStatsModule.WeaponStats

local Auto = {}
Auto.__index = Auto

function Auto.new(stats: WeaponStats, rayModule: table)
    local self = setmetatable({
        WeaponStats = stats,
        RayModule = rayModule,

        CanFire = true,
        Shooting = true,

        Mouse = Mouse.new(),
        Cleaner = Trove.new(),

        Events = {
            Attacked = Signal.new(),
            TriggerReload = Signal.new()
        }
    }, Auto)
    return self
end

function Auto:SetCanFire(bool: boolean)
    self.CanFire = bool
end

function Auto:Attack()
    local mouse = self.Mouse :: Mouse

    while mouse:IsLeftDown() and self.CanFire and not self.Shooting do
        self.Shooting = true
        task.spawn(function() self.RayModule:Hitscan() self.RayModule:Draw() end)
        self.Events.Attacked:Fire()
        task.wait(1/self.WeaponStats.FireRate)
    end
end

function Auto:Destroy()
    self.Cleaner:Destroy()
end

return Auto