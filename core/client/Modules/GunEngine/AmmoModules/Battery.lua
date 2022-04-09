local Signal = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Trove = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))

local Battery = {}
Battery.__index = Battery
Battery.__Tag = "Battery"

function Battery.new(heatRate: number, coolTime: number, coolWait: number, batteryMin: number, batteryMax: number, shotsDeplete: number, shotsTable)
    local self = setmetatable({
        BatteryMin = batteryMin,
        BatteryMax = batteryMax,
        ShotsDeplete = shotsDeplete,

        HeatRate = heatRate;
        CoolTime = coolTime;
        CoolWait = coolWait;

        Random = Random.new();
        ShotsTable = shotsTable;

        CurrentHeat = 0;
        Overheated = false;

        CurrentBattery = 100;

        Events = {
            Reloading = Signal.new();
            AmmoChanged = Signal.new();
        }

    }, Battery)
    return self
end

function Battery:IsOverheated(): boolean
    return self.Overheated
end

function Battery:Recharge()
    self.CurrentBattery = 100
end

function Battery:DepleteBattery()
    local random = self.Random :: Random
    
    local batteryRemove = random:NextInteger(self.BatteryMin, self.BatteryMax)
    local newBattery = self.CurrentBattery - batteryRemove

    if newBattery <= 0 then
        newBattery = 0
    end

    self.CurrentBattery = newBattery
end

function Battery:CanFire(): boolean
    return (not (self.CurrentBattery == 0) and not self.Overheated)
end

-- abstract function that all ammo modules have to decrease their ammo. should just call another function
function Battery:Fire()
    self:Heat()
end

function Battery:Heat()
    if self.ShotsTable.NumShots >= self.ShotsDeplete then
        self:DepleteBattery()
    end

    local lastShotTimestamp = self.ShotsTable.LastShot.Timestamp

    local heatRate = self.HeatRate :: number
    local newHeatRate = (self.CurrentHeat + heatRate) :: number

    if newHeatRate >= 100 then
        self.CurrentHeat = 100
        self.Overheated = true

        self.Events.Reloading:Fire(true)
    else
        self.CurrentHeat = newHeatRate
    end

    self.Events.AmmoChanged:Fire(self.CurrentHeat)

    if not self.Overheated then
        task.wait(self.CoolWait)
    end

    local frameWait = 1/10
    local coolRate = 10 / self.CoolTime :: number

    local loopActive = true
    -- this while loop is only ever spawned in a signal connection, therefore we don't need to spawn a new coroutine
    while loopActive and self.ShotsTable.LastShot.Timestamp == lastShotTimestamp do
        task.wait(frameWait)

        local newHeat = self.CurrentHeat - coolRate
        if newHeat <= 0 then
            self.Overheated = false
            self.Events.Reloading:Fire(false) -- set battery color somewhere
            
            newHeat = 0
            loopActive = false
        end

        self.CurrentHeat = newHeat
        self.Events.AmmoChanged:Fire(self.CurrentHeat)
    end

    -- print(self.CurrentHeat)
end

return Battery