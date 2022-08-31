type BatteryStats = {
    BatteryMin: number,
    BatteryMax: number,
    ShotsDeplete: number,

    HeatRate: number;
    CoolTime: number;
    CoolWait: number;

    Random: typeof(Random.new());
    ShotsTable: {};

    CurrentHeat: number;
    Overheated: boolean;

    CurrentBattery: number;
}

local Battery = {}

function Battery.GetStats(heatRate: number, coolTime: number, coolWait: number, batteryMin: number, batteryMax: number, shotsDeplete: number, shotsTable)
    return {
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
    }
end

function Battery.DepleteBattery(weaponStats: BatteryStats)
    local random = weaponStats.Random :: Random
    
    local batteryRemove = random:NextInteger(weaponStats.BatteryMin, weaponStats.BatteryMax)
    local newBattery = weaponStats.CurrentBattery - batteryRemove

    if newBattery <= 0 then
        newBattery = 0
    end

    weaponStats.CurrentBattery = newBattery
end

function Battery.CanFire(weaponStats: BatteryStats)
    return (not (weaponStats.CurrentBattery == 0) and not weaponStats.Overheated)
end

function Battery.Heat(weaponStats: BatteryStats)
    if weaponStats.ShotsTable.NumShots % weaponStats.ShotsDeplete == 0 then
        Battery.DepleteBattery(weaponStats)
    end

    local lastShotTimestamp = weaponStats.ShotsTable.LastShot.Timestamp

    local heatRate = weaponStats.HeatRate :: number
    local newHeatRate = (weaponStats.CurrentHeat + heatRate) :: number

    if newHeatRate >= 100 then
        weaponStats.CurrentHeat = 100
        weaponStats.Overheated = true

    else
        weaponStats.CurrentHeat = newHeatRate
    end

    if not weaponStats.Overheated then
        task.wait(weaponStats.CoolWait)
    end

    local frameWait = 1/10
    local coolRate = 10 / weaponStats.CoolTime :: number

    local loopActive = true
    -- this while loop is only ever spawned in a signal connection, therefore we don't need to spawn a new coroutine
    while loopActive and weaponStats.ShotsTable.LastShot.Timestamp == lastShotTimestamp do
        task.wait(frameWait)

        local newHeat = weaponStats.CurrentHeat - coolRate
        if newHeat <= 0 then
            weaponStats.Overheated = false
            
            newHeat = 0
            loopActive = false
        end

        weaponStats.CurrentHeat = newHeat
    end
end

return Battery