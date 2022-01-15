local WeaponStatsModule = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Stats"):WaitForChild("WeaponStats"))

type WeaponStats = WeaponStatsModule.WeaponStats

local Auto = {}
Auto.__index = Auto

function Auto.new(stats: WeaponStats)
    local self = setmetatable({}, Auto)
    return self
end

function Auto:Destroy()
    
end

return Auto