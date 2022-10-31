-- tom
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")

local tcs = require(Shared:WaitForChild("tcs"))
local Courier = require(Shared:WaitForChild("courier"))
local WeaponStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("WeaponStats_V2"))
local GadgetStatsModule = require(Shared:WaitForChild("Configurations"):WaitForChild("GadgetStats"))
local Trove = require(Shared:WaitForChild("util", 5):WaitForChild("Trove", 5))

local Weapons = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Weapons")
local Grenades = require(script.Grenades)

local BulletRenderer = require(script.Modules.BulletRenderer)
local Battery = require(script.Modules.Battery)
local FireModes = require(script.Modules.FireModes)

local chargeWait = require(script.functions.chargeWait)
local recursivelyFindHealthComponentInstance = require(script.functions.recursivelyFindHealthComponentInstance)
local createDamageIndicator = require(script.functions.createDamageIndicator)

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Hit = SoundService.Sounds.Hit
Hit.Pitch = 2
local EquipDebounce = false

local EQUIP_WAIT = 0.3

type WeaponStats = typeof(WeaponStatsModule)

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

export type Gun = {
    WeaponStats: WeaponStats
}

local Cleaner = Trove.new()

local function functor(f: (Player, Vector3, Vector3, any) -> any)
    if f == nil then
        error("functor is nil")
    end
    return f
end

local GunEngine = {
    EquippedWeaponModel = nil,
}

function GunEngine:Start()
    if Player.Character == nil then
        Player.CharacterAdded:Wait()
    end

    Cleaner:Add(Courier:Listen("DrawRay"):Connect(function(player: Player, startPosition: Vector3, endPosition: Vector3, weaponName: string)
        local weaponStats = WeaponStatsModule[weaponName]

        if weaponStats then
            functor(BulletRenderer["Draw"..weaponStats.BulletType])(player, startPosition, endPosition, weaponStats.BulletCache)
        else
            error("WeaponStats don't exist??")
        end
    end))

    Cleaner:Add(Courier:Listen("RenderGrenade"):Connect(function(player: Player, position: Vector3, direction: Vector3, movementSpeed: number, grenade: string)
        self:RenderGrenadeForOtherPlayer(player, position, direction, movementSpeed, grenade)
    end))
end

function GunEngine:RenderGrenadeForLocalPlayer(grenadeName: string)
    local hrp = Player.Character.HumanoidRootPart
    local leftArm = Player.Character["Left Arm"] :: Part

    local GadgetStats = GadgetStatsModule[grenadeName]
    assert(GadgetStats, "No grenade stats for the grenade")
    
    if Player.Character ~= nil and leftArm ~= nil and Mouse.UnitRay.Direction ~= nil and hrp ~= nil and Player:GetAttribute("LocalSprinting") == false and Player:GetAttribute("Health") > 0 then
        Player:SetAttribute("Throwing", true)
        
        task.wait(.5) -- animation wait
        if Player:GetAttribute("Health") > 0 then
            Courier:Send("RenderGrenade", leftArm.Position, Mouse.UnitRay.Direction, hrp.AssemblyLinearVelocity, grenadeName)
            Grenades:RenderNade(Player, leftArm.Position, Mouse.UnitRay.Direction, hrp.AssemblyLinearVelocity, GadgetStats)
        end
    end
end

function GunEngine:RenderGrenadeForOtherPlayer(player: Player, position: Vector3, direction: Vector3, movementSpeed: Vector3, grenade: string)
    local stats = GadgetStatsModule[grenade]
    assert(stats ~= nil, "No gadget stats for "..grenade)
    Grenades:RenderNade(player, position, direction, movementSpeed, stats)
end

function GunEngine.EquipWeapon(weaponStats, mutableStats, weaponModel)
    if Player:GetAttribute("InSeat") == true then return false end
    print("here", EquipDebounce)
    if EquipDebounce then return false end
    EquipDebounce = true
    task.delay(EQUIP_WAIT, function() EquipDebounce = false end)

    mutableStats.CanShoot = true

    Courier:Send("WeldWeapon", weaponModel, false)

    if weaponModel.Handle:FindFirstChild("Equip") then
        weaponModel.Handle.Equip:Play()
    end

    GunEngine.EquippedWeaponModel = weaponModel

    Player:SetAttribute("EquippedWeapon", weaponStats.Name)
end

function GunEngine.UnequipWeapon(weaponStats, mutableStats, weaponModel)
    if EquipDebounce then return false end
    EquipDebounce = true
    task.delay(EQUIP_WAIT, function() EquipDebounce = false end)

    mutableStats.CanShoot = false
    
    if weaponModel.Handle:FindFirstChild("Unequip") then
        weaponModel.Handle.Unequip:Play()
    end

    Player:SetAttribute("EquippedWeapon", "")
    
    GunEngine.EquippedWeaponModel = nil
    
    Courier:Send("WeldWeapon", weaponModel, true)
end

function GunEngine.CheckHitPart(hitPart: Instance, weaponStats, cursorComponent)
    local healthComponentInstance = recursivelyFindHealthComponentInstance(hitPart)

    print(hitPart, hitPart.Parent, healthComponentInstance)
    if healthComponentInstance ~= nil and healthComponentInstance ~= Player then
        cursorComponent:Hitmark()
        Hit:Play()
        Courier:Send("AttemptDealDamage", healthComponentInstance, weaponStats.Name, hitPart.Name)

        local shields = healthComponentInstance:GetAttribute("Shields")
        local headshot = hitPart.Name == "Head"
        local potentialDamage = if headshot then weaponStats.Damage * weaponStats.HeadshotMultiplier else weaponStats.Damage
        -- if shields > 0 and shields - potentialDamage <= 0 then
        --     SoundService.Sounds.ShieldCrack:Play()
        -- end

        createDamageIndicator(hitPart, potentialDamage, shields > 0, headshot)
    end
end

function GunEngine.Attack(weaponStats, mutableStats)
    FireModes.GetFireMode(weaponStats.Trigger)(weaponStats, mutableStats, GunEngine.EquippedWeaponModel, GunEngine.CheckHitPart, Battery.Heat)
    Player:SetAttribute("LocalCanSprint", true)
end

function GunEngine.TurretAttack(weaponStats, mutableStats, turretModel: Model)
    mutableStats.MouseDown = true

    if Battery.CanFire(mutableStats) == false then
        if turretModel.Barrel:FindFirstChild("Unavailable") then
            turretModel.Barrel.Unavailable:Play()
        end

        return
    end

    Player:SetAttribute("LocalSprinting", false)

    FireModes.GetFireMode(weaponStats.Trigger)(weaponStats, mutableStats, turretModel, GunEngine.CheckHitPart, Battery.Heat)
end

function GunEngine.MouseDown(weaponStats, mutableStats)
    if Player:GetAttribute("LocalRolling") == true then return end
    if Player:GetAttribute("LocalSprinting") == true then
        Player:SetAttribute("LocalSprinting", false)
    end
    if EquipDebounce then return end
    mutableStats.MouseDown = true

    if Battery.CanFire(mutableStats) == false then
        if GunEngine.EquippedWeaponModel.Barrel:FindFirstChild("Unavailable") then
            GunEngine.EquippedWeaponModel.Barrel.Unavailable:Play()
        end

        return
    end

    Player:SetAttribute("LocalCanSprint", false)
    if weaponStats.ChargeWait > 0 then
        Player:SetAttribute("ChargeWait", weaponStats.ChargeWait)
        Player:SetAttribute("Charging", true)
        if chargeWait(weaponStats.ChargeWait) then
            GunEngine.Attack(weaponStats, mutableStats)
        end
        Player:SetAttribute("Charging", false)
    else
        GunEngine.Attack(weaponStats, mutableStats)
    end
end

function GunEngine.MouseUp(weaponStats, mutableStats)
    mutableStats.MouseDown = false
end

function GunEngine.GetShotsTable()
    return {
        NumShots = 0,
        HitShots = 0,
        Headshots = 0,
        LastShot = {
            StartPosition = nil,
            EndPosition = nil,
            Timestamp = tick()
        } :: LastShotData
    } :: ShotsTable
end

function GunEngine.LoadAnimations(weaponStats)
    local animationComponent = tcs.get_component(Player, "AnimationHandler")
    local weaponsFolder = Weapons[weaponStats.Name] :: Folder

    for _, animation: Animation in pairs(weaponsFolder.Anims:GetChildren()) do
        local ani = animation:Clone()
        ani.Name = weaponStats.Name..""..ani.Name
        animationComponent:Load(ani)
    end
end

-- mutable stats are the battery stats combined with the shots table and
-- the standard aiming and default stats
function GunEngine.GetMutableStats(stats)
    local mutableStats = Battery.GetStats(stats.HeatRate, stats.CoolTime, stats.CoolWait, stats.BatteryDepletionMin, stats.BatteryDepletionMax, stats.ShotsDeplete, GunEngine.GetShotsTable())

    mutableStats.AimBuff = 3
    mutableStats.CurrentRecoil = 0

    mutableStats.Equipped = false
    mutableStats.Aiming = false
    mutableStats.MouseDown = false

    mutableStats.CanShoot = true
    mutableStats.Shooting = false

    if stats.NumBarrels > 1 then
        mutableStats.CurrentBarrel = 1
    end

    return mutableStats
end

return GunEngine