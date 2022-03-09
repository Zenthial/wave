local WeaponStatsModule = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local Rosyn = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Rosyn"))
local Trove = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Trove"))
local Signal = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Signal"))
local Input = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input"))
local Mouse = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("Input")).Mouse

local MouseComponentModule = require(script.Parent.Parent.Parent.Parent.Components.Player.Mouse)

local Player = game.Players.LocalPlayer

type WeaponStats = WeaponStatsModule.WeaponStats
type GunModelAdditionalInfo = {
    Barrel: Part,
    Grip: Part
}
type GunModel = Model & GunModelAdditionalInfo

local Auto = {}
Auto.__index = Auto
Auto.__Tag = "Auto"

function Auto.new(stats: WeaponStats, bulletModule: table, gunModel, mutableStats)
    local self = setmetatable({
        WeaponStats = stats,
        BulletModule = bulletModule,
        MutableStats = mutableStats,

        GunModel = gunModel,

        CanFire = true,
        Shooting = true,

        Mouse = Mouse.new(),
        Cleaner = Trove.new(),

        MouseComponent = Rosyn.GetComponent(Player, MouseComponentModule) :: typeof(MouseComponentModule),
        MouseInput = Input.Mouse.new(),

        Events = {
            Attacked = Signal.new(),
            TriggerReload = Signal.new(),
            CheckHitPart = Signal.new()
        }
    }, Auto)
    return self
end

function Auto:SetCanFire(bool: boolean)
    self.CanFire = bool
end

function Auto:Attack()
    local mouse = self.MouseComponent :: typeof(MouseComponentModule)
    local mouseInput = self.MouseInput :: typeof(Input.Mouse)

    if not self.Shooting then
        -- make it a do while because of weird edge cases in function calling
        repeat
            self.Shooting = true
    
            task.spawn(function()
                local gunModel = self.Model :: GunModel
                if gunModel.Barrel ~= nil then            
                    local hit, target = mouse:Raycast(gunModel.Barrel.Position, self.WeaponStats, self.MutableStats.Aiming, self.MutableStats.CurrentRecoil, self.MutableStats.AimBuff)
                    
                    if hit ~= nil then
                        self.Events.CheckHitPart:Fire(hit)
                    end
    
                    self.BulletModule:Draw(target)
                end
            end)
    
            self.Events.Attacked:Fire()
            task.wait(1/self.WeaponStats.FireRate)
        until self.MutableStats == false or not self.CanFire
    end
end

function Auto:Destroy()
    self.Cleaner:Destroy()
end

return Auto