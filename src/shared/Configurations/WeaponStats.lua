local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local Types = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Types"))
local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))
local AnimationData = require(script.Parent.Parent.Modules.AnimationData)

type AnimationData = Types.AnimationData

type HandleWeld = {
    Limb: string,
    C0: CFrame,
    C1: CFrame
}

export type WeaponStats_T = {
    Name: string,
    FullName: string,
    Category: string,
    Description: string,
    QuickDescription: string,
    
    WeaponCost: number, -- backwards armory compatibility?    
    
    GunType: string,
    
    DamageCalculationFunction: (number, number) -> number | nil, -- damage, distance, alteredDamage
    Damage: number,
    HeadshotMultiplier: number,
    VehicleMultiplier: number,
    
    ChargeWait: number, -- think MSI
    
    FireMode: string,
    BulletType: string, -- for things like the msi, pbw, anything else
    BulletModel: Model | BasePart,
    BulletCache: PartCache.PartCache,

    CanSprint: boolean,
    CanCrouch: boolean,
    
    NumBarrels: number,
    NumHandles: number,
    Holster: string,
    HandleWelds: {HandleWeld},
    
    EquipTime: number,
    
    FireRate: number,
    MaxSpread: number,
    MinSpread: number,
    
    AmmoType: string, -- battery, default ammo
    
    -- if default ammo
    Ammo: number | nil,
    ReloadTime: number | nil,

    -- if battery based
    BatteryDepletionMin: number,
    BatteryDepletionMax: number,
    ShotsDeplete: number,

    HeatRate: number,
    CoolTime: number,
    CoolWait: number,

    Animations: {AnimationData}
}

-- all of the below tables, except the caches, are just enums
local GunTypes = {
    Auto = "Auto",
    Semi = "Semi",
}

local FireMode = {
    Single = "Single",
    Shotgun = "Shotgun",
    Burst = "Burst",
}

local BulletType = {
    Ray = "Ray",
    Lighting = "Lighting",
    Projectile = "Projectile",
}

local AmmoType = {
    Battery = "Battery",
    Ammo = "Ammo"
}

local Bullets = {
    Default = BulletAssets:WaitForChild("Default")
}

local Caches = {
    DefaultCache = nil
}

-- don't create extra parts that are just never used on the server
-- WeaponStats.Cache should never be touched on the server anyway
if RunService:IsClient() then
    CollectionService:AddTag(Bullets.Default, "Ignore")
    Caches.DefaultCache = PartCache.new(Bullets.Default, 200)
end

local Holsters = {
    Back = "Back",
    TorsoModule = "TorsoModule",
    Hip = "Hip",
    RightArmModule = "RightArmModule",
    LeftArmModule = "LeftArmModule",
    Melee = "Melee"
}

return {
    ["W17"] = {
        Name = "W17",
        FullName = "Assault Rifle",
        Category = "Assault",
        Description = "The WIJ Mark 17 Individual Defense and Combat Initiator has proven to be effective under many combat scenarios. It is a highly popular rifle throughout the WIJ forces, as it is very durable. The W17 Assault Rifle is produced on the planet Gorius 5 by GORIUS ARMORIES for the WIJ Corporation.",
        QuickDescription = "Automatic, Single Shot",
        
        WeaponCost = 0, -- backwards armory compatibility?    
        
        GunType = GunTypes.Auto,
        
        DamageCalculationFunction = function(damage, _)
            return damage
        end, -- damage, distance, alteredDamage
        Damage = 8,
        HeadshotMultiplier = 1.7,
        VehicleMultiplier = 1,

        ChargeWait = 0,

        FireMode = FireMode.Single,
        BulletType = BulletType.Ray, -- for things like the msi, pbw, anything else
        BulletModel = Bullets.Default,
        BulletCache = Caches.DefaultCache,

        CanSprint = true,
        CanCrouch = true,
        
        NumBarrels = 1,
        NumHandles = 1,
        Holster = Holsters.Back,
        HandleWelds = {
            {
                limb = "Right Arm",
				C0 = CFrame.new(0, -0.5, -0.25) * CFrame.Angles(math.rad(-90),math.rad(180),0),
				C1 = CFrame.new()
            },
        },

        EquipTime = 0.3,
        
        FireRate = 11,
        MaxSpread = 2.5,
        MinSpread = 0.5,
        
        AmmoType = AmmoType.Battery, -- battery, default ammo
        
        -- if default ammo
        Ammo = nil,
        ReloadTime = nil,

        -- if battery based
        BatteryDepletionMin = 2,
        BatteryDepletionMax = 3,
        ShotsDeplete = 10,

        HeatRate = 2,
        CoolTime = 3,
        CoolWait = 0.3,

        Animations = {
            AnimationData.new("W17Equip", 1429821058),
            AnimationData.new("W17Hold", 1429816077),
            AnimationData.new("W17Sprint", 8681795992),
            AnimationData.new("W17Melee", 1427432032),
        }
    }
}