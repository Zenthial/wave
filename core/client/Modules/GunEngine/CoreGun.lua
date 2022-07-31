local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local tcs = require(ReplicatedStorage.Shared.tcs)

local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))
local Signal = require(Shared:WaitForChild("util", 5):WaitForChild("Signal", 5))
local Mouse = require(Shared:WaitForChild("util", 5):WaitForChild("Input", 5)).Mouse.new()

local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")

local ClientComm = require(script.Parent.Parent.ClientComm)
local comm = ClientComm.GetClientComm()

local Player = Players.LocalPlayer
local PlayerGui = Player.PlayerGui

local AttackModules = script.Parent.AttackModules
local AmmoModules = script.Parent.AmmoModules
local BulletModules = script.Parent.BulletModules

type WeaponStats = WeaponStatsModule.WeaponStats_T
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
type GunModelAdditionalInfo = {
    Barrel: Part,
    Handle: Part
}
type GunModel = Model & GunModelAdditionalInfo

-- this block needs to be improved

local LoadedModules = {
    Attack = {},
    Ammo = {},
    Bullet = {}
}

local function loadModulesOfType(tble, folder)
    for _, v in pairs(folder:GetChildren()) do
        tble[v.Name] = require(v)
    end
end

loadModulesOfType(LoadedModules.Attack, AttackModules)
loadModulesOfType(LoadedModules.Ammo, AmmoModules)
loadModulesOfType(LoadedModules.Bullet, BulletModules)

local function getAttackModule(stats: WeaponStats, bulletModule: table, gunModel, mutableStats, storedShots: ShotsTable): table
    local mod = LoadedModules.Attack[stats.Trigger]
    assert(mod, "Attack module does not exist for "..tostring(stats.Trigger).." on "..stats.Name)
    if mod then
        return mod.new(stats, bulletModule, gunModel, mutableStats, storedShots)
    end
end

local function getAmmoModule(stats: WeaponStats, shotsTable: ShotsTable): table
    local mod = LoadedModules.Ammo[stats.AmmoType]
    if mod then
        return mod.new(stats.HeatRate, stats.CoolTime, stats.CoolWait, stats.BatteryDepletionMin, stats.BatteryDepletionMax, stats.ShotsDeplete, shotsTable)
    end
end

local function getBulletModule(gunModel: GunModel, stats: WeaponStats)
    local mod = LoadedModules.Bullet[stats.BulletType]
    assert(mod, "Bullet module does not exist for "..tostring(stats.BulletType).." on "..stats.Name)
    if mod then
        return mod.new(gunModel, stats)
    end
end

local function recursivelyFindHealthComponentInstance(part: BasePart)
    if part:GetAttribute("Health") ~= nil then
        return part
    else
        local player: Player | nil = Players:GetPlayerFromCharacter(part)
        if player then
            return player
        elseif part.Parent ~= workspace then
            return recursivelyFindHealthComponentInstance(part.Parent)
        else
            return nil
        end
    end
end

local function chargeWait(waitTime: number): boolean
    local retVal = true
    local con
   
    task.spawn(function()
        con = Mouse.LeftUp:Connect(function()
            retVal = false
            Player:SetAttribute("Charging", false)
            con:Disconnect()
        end)
    end)
    
    task.wait(waitTime)

    if retVal == false then
        return false
    else
        con:Disconnect()
        return Mouse:IsLeftDown()
    end
end

local CoreGun = {}
CoreGun.__index = CoreGun
CoreGun.__Tag = "CoreGun"

function CoreGun.new(weaponStats: WeaponStats, gunModel: GunModel)
    local storedShots: ShotsTable = {
        NumShots = 0,
        HitShots = 0,
        Headshots = 0,
        LastShot = {
            StartPosition = nil,
            EndPosition = nil,
            Timestamp = tick()
        } :: LastShotData
    }

    local mutableStats = {
        AimBuff = 3,
        CurrentRecoil = 0,

        Equipped = false,
        Aiming = false,
        MouseDown = false,
    }

    local bulletModule = getBulletModule(gunModel, weaponStats)
    local ammoModule = getAmmoModule(weaponStats, storedShots)
    local attackModule = getAttackModule(weaponStats, bulletModule, gunModel, mutableStats, storedShots)
    
    local weldWeaponFunction = comm:GetFunction("WeldWeapon") :: (BasePart, boolean) -> boolean
    local attemptDealDamageFunction = comm:GetFunction("AttemptDealDamage") :: (BasePart, string, string) -> boolean

    local animationComponent = tcs.get_component(Player, "AnimationHandler")
    local cursorComponent = tcs.get_component(PlayerGui:WaitForChild("Cursor"):WaitForChild("Cursor"), "Cursor")

    local weaponsFolder = Weapons[weaponStats.Name] :: Folder
    assert(weaponsFolder:FindFirstChild("Anims"), "Anims folder does not exist for "..weaponStats.Name)

    for _, animation: Animation in pairs(weaponsFolder.Anims:GetChildren()) do
        local ani = animation:Clone()
        ani.Name = weaponStats.Name..""..ani.Name
        animationComponent:Load(ani)
    end

    local ammoChanged = Signal.new()
    local fired = Signal.new()

    local cleaner = Trove.new();
    cleaner:Add(ammoModule.Events.Reloading:Connect(function(bool: boolean)
        attackModule:SetCanFire(not bool)
        
        if bool == true then
            if gunModel.Barrel:FindFirstChild("Overheat") then
                gunModel.Barrel.Overheat:Play()
            end
        end

        Player:SetAttribute("Reloading", bool)
    end))

    cleaner:Add(ammoModule.Events.AmmoChanged:Connect(function(ammo): boolean
        ammoChanged:Fire(ammo)
    end))

    cleaner:Add(attackModule.Events.Attacked:Connect(function()
        Player:SetAttribute("Firing", true)
        if gunModel.Barrel:FindFirstChild("Fire") then
            gunModel.Barrel.Fire:Play()
        end
        ammoModule:Fire()
    end))

    cleaner:Add(attackModule.Events.StoppedShooting:Connect(function()
        Player:SetAttribute("Firing", false)
        fired:Fire(1/weaponStats.FireRate)
    end))

    cleaner:Add(attackModule.Events.CheckHitPart:Connect(function(hitPart)
        local healthComponentInstance = recursivelyFindHealthComponentInstance(hitPart)

        print(hitPart, hitPart.Parent, healthComponentInstance)
        if healthComponentInstance ~= nil and healthComponentInstance ~= Player then
            cursorComponent:Hitmark()
            gunModel.Handle.Hit:Play()
            attemptDealDamageFunction(healthComponentInstance, weaponStats.Name, hitPart.Name)
        end
    end))

    cleaner:Add(gunModel.Destroying:Connect(function()
        Player:SetAttribute("EquippedWeapon", "")
    end))

    return setmetatable({
        Model = gunModel,

        WeaponStats = weaponStats,
        StoredShots = storedShots,
        MutableStats = mutableStats,
        
        AttackModule = attackModule,
        AmmoModule = ammoModule,
        BulletModule = bulletModule,

        WeldWeaponFunction = weldWeaponFunction,

        Events = {
            AmmoChanged = ammoChanged,
            Fired = fired
        },

        Cleaner = cleaner,
    }, CoreGun)
end

function CoreGun:Equip()
    local result = self.WeldWeaponFunction(self.Model, false) :: boolean
    if result == false then
        error("Weld failed, does this weapon have stats?")
    end
    self.MutableStats.Equipped = true
    if self.Model.Handle:FindFirstChild("Equip") then
        self.Model.Handle.Equip:Play()
    end
    Player:SetAttribute("EquippedWeapon", self.WeaponStats.Name)
end

function CoreGun:Unequip()
    local result = self.WeldWeaponFunction(self.Model, true) :: boolean
    if result == false then
        error("Weld failed, does this weapon have stats?")
    end
    self.MutableStats.Equipped = false
    if self.Model.Handle:FindFirstChild("Unequip") then
        self.Model.Handle.Unequip:Play()
    end
    Player:SetAttribute("EquippedWeapon", "")
end

function CoreGun:MouseDown()
    self.MutableStats.MouseDown = true
    self:Fire()
end

function CoreGun:MouseUp()
    self.MutableStats.MouseDown = false
end

function CoreGun:Fire()
    if self.AmmoModule:CanFire() then
        Player:SetAttribute("LocalSprinting", false)
        if self.WeaponStats.ChargeWait > 0 then
            Player:SetAttribute("ChargeWait", self.WeaponStats.ChargeWait)
            Player:SetAttribute("Charging", true)
            if chargeWait(self.WeaponStats.ChargeWait) then
                self.AttackModule:Attack()
            end
            Player:SetAttribute("Charging", false)
        else
            self.AttackModule:Attack()
        end
    else
        if self.Model.Barrel:FindFirstChild("Unavailable") then
            self.Model.Barrel.Unavailable:Play()
        end
    end
end

function CoreGun:Reload()
    if self.WeaponStats.AmmoType ~= "Battery" then
        self.AmmoModule:Reload()
    end
end

function CoreGun:Destroy()
    self.Cleaner:Destroy()
end

return CoreGun
