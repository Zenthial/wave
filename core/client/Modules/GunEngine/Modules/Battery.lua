local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))

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

    BatteryChanged: typeof(Signal.new()),
    HeatChanged: typeof(Signal.new()),
    OverheatChanged: typeof(Signal.new()),
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

        BatteryChanged = Signal.new(),
        HeatChanged = Signal.new(),
        OverheatChanged = Signal.new(),
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
    weaponStats.BatteryChanged:Fire(weaponStats.CurrentBattery)
end

function Battery.CanFire(weaponStats: BatteryStats)
    return (not (weaponStats.CurrentBattery == 0) and not weaponStats.Overheated)
end

function Battery.Heat(weaponStats: BatteryStats, cursorUIComponent)
    if weaponStats.ShotsTable.NumShots % weaponStats.ShotsDeplete == 0 then
        Battery.DepleteBattery(weaponStats)
    end
    
    local lastShotTimestamp = tick()
    weaponStats.ShotsTable.LastShot.Timestamp = lastShotTimestamp

    local heatRate = weaponStats.HeatRate :: number
    local newHeatRate = (weaponStats.CurrentHeat + heatRate) :: number

    if newHeatRate >= 100 then
        weaponStats.CurrentHeat = 100
        weaponStats.HeatChanged:Fire(weaponStats.CurrentHeat)
        weaponStats.Overheated = true
        weaponStats.OverheatChanged:Fire(true)
        cursorUIComponent:SetOverheated(true)
    else
        weaponStats.CurrentHeat = newHeatRate
        weaponStats.HeatChanged:Fire(weaponStats.CurrentHeat)
    end

    task.delay(weaponStats.CoolWait, function()
        local frameWait = 1 / 10
        local coolRate = 10 / weaponStats.CoolTime :: number
    
        local loopActive = true
        while loopActive and weaponStats.ShotsTable.LastShot.Timestamp == lastShotTimestamp do
            task.wait(frameWait)
    
            local newHeat = weaponStats.CurrentHeat - coolRate
            if newHeat <= 0 then
                weaponStats.Overheated = false
                weaponStats.OverheatChanged:Fire(false)
                cursorUIComponent:SetOverheated(false)
                
                newHeat = 0
                loopActive = false
            end
    
            weaponStats.CurrentHeat = newHeat
            weaponStats.HeatChanged:Fire(weaponStats.CurrentHeat)
        end
    end)
end

return Battery