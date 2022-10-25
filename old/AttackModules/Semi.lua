local WeaponStatsModule = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local tcs = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("tcs"))
local Trove = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Input = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Mouse = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input")).Mouse

local Player = game.Players.LocalPlayer

type WeaponStats = WeaponStatsModule.WeaponStats_T
type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local Semi = {}
Semi.__index = Semi

function Semi.new(stats: WeaponStats, bulletModule: table, gunModel, mutableStats, storedShots)
    local self = setmetatable({
        WeaponStats = stats,
        BulletModule = bulletModule,
        MutableStats = mutableStats,
        StoredShots = storedShots,

        GunModel = gunModel,

        CanFire = true,
        Shooting = false,

        Mouse = Mouse.new(),
        Cleaner = Trove.new(),

        MouseComponent = tcs.get_component(Player, "Mouse") --[[:await()]],
        MouseInput = Input.Mouse.new(),

        Events = {
            Attacked = Signal.new(),
            StoppedShooting = Signal.new(),
            TriggerReload = Signal.new(),
            CheckHitPart = Signal.new()
        }
    }, Semi)
    return self
end

function Semi:SetCanFire(bool: boolean)
    self.CanFire = bool
end

function Semi:Attack()
    local mouse = self.MouseComponent
    local mouseInput = self.MouseInput :: typeof(Input.Mouse)

    if not self.Shooting then
        -- make it a do while because of weird edge cases in function calling
        self.Shooting = true
    
        task.spawn(function()
            local gunModel = self.GunModel :: GunModel
            if gunModel ~= nil and gunModel.Barrel ~= nil then
                if self.WeaponStats.FireMode == "Launcher" then
                    self.StoredShots.LastShot.StartPosition = gunModel.Barrel.Position
                    self.StoredShots.LastShot.EndPosition = mouse:GetPosition()
                    self.StoredShots.LastShot.Timestamp = tick()
                    local _ = self.BulletModule:Draw(mouse:GetPosition())
                else
                    local hit, target = mouse:Raycast(gunModel.Barrel.Position, self.WeaponStats, self.MutableStats.Aiming, self.MutableStats.CurrentRecoil, self.MutableStats.AimBuff)
                    
                    if hit ~= nil then
                        self.Events.CheckHitPart:Fire(hit)
                    end
    
                    self.StoredShots.LastShot.StartPosition = gunModel.Barrel.Position
                    self.StoredShots.LastShot.EndPosition = target
                    self.StoredShots.LastShot.Timestamp = tick()
                    local _ = self.BulletModule:Draw(target)
                end      
            end
        end)

        self.Events.Attacked:Fire()
        task.wait(1/self.WeaponStats.FireRate)
        -- print(self.MutableStats.MouseDown == false, not self.CanFire)
        self.Events.StoppedShooting:Fire()
        self.Shooting = false
    end
end

function Semi:Destroy()
    self.Cleaner:Destroy()
end

return Semi