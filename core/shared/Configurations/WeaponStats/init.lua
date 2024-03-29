local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BulletAssets = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Assets"):WaitForChild("Bullets")

local PartCache = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("util"):WaitForChild("PartCache"))

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
    
    Primary: boolean,
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
        
        Primary = true,
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
    } :: WeaponStats_T,

    ["W18"] = {
        Name = "W18",
		FullName = "Combat Rifle",
		Category = "Assault",
		Description = "Special operations run by Shock Troopers demanded a more versatile weapon than the W17, therefore it was completely re-designed to produce a shorter-barreled version. The resulting rifle is fitted with an EM scope and a suppressor. This rifle is perfect for Shock Troopers as a soldier can ensure long-range hits and maintain concealment.",
		QuickDescription = "Automatic, Single Shot, Silenced",

        WeaponCost = 2000, -- backwards armory compatibility?    
        
        Primary = true,
        GunType = GunTypes.Auto,

        DamageCalculationFunction = function(damage, _)
            return damage
        end, -- damage, distance, alteredDamage
        Damage = 8,
        HeadshotMultiplier = 1.75,
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
        MaxSpread = 2,
        MinSpread = 0.25,
        
        AmmoType = AmmoType.Battery, -- battery, default ammo
        
        -- if default ammo
        Ammo = nil,
        ReloadTime = nil,

        -- if battery based
        BatteryDepletionMin = 2,
        BatteryDepletionMax = 3,
        ShotsDeplete = 12,

        HeatRate = 2,
        CoolTime = 3,
        CoolWait = 0.3,
    } :: WeaponStats_T,

    ["Y14"] = {
        Name = "Y14",
        FullName = "YOLTOR no. 14 Phaser Pistol",
        Category = "Handgun",
        Description = "The YOLTOR no. 14 phaser pistol is the standard-issue sidearm issued to all WIJ forces with a history dating back to the conception of the alliance. With a highly efficient energy converter and easy handling, the Y14 serves well in any combat situation. The Y14 is widely considered the best sidearm on the market today.",

        WeaponCost = 0,

        Primary = false,
        GunType = GunTypes.Semi,

        DamageCalculationFunction = function(damage, _)
            return damage
        end, -- damage, distance, alteredDamage
        Damage = 8,
        HeadshotMultiplier = 1.6,
        VehicleMultiplier = 1,

        ChargeWait = 0,

        FireMode = FireMode.Single,
        BulletType = BulletType.a, -- for things like the msi, pbw, anything else
        BulletModel = Bullets.Default,
        BulletCache = Caches.DefaultCache,

        CanSprint = true,
        CanCrouch = true,

        NumBarrels = 1,
        NumHandles = 1,
        Holster = Holsters.Hip,
        HandleWelds = {
            {	limb = "Right Arm",
				C0 = CFrame.new(0, -.5, -.25) * CFrame.Angles(math.rad(-90), 0, 0),
				C1 = CFrame.new()
			}
        },

        EquipTime = 0.1,

        FireRate = 15,
        MaxSpread = 2.5,
        MinSpread = 0.5,

        AmmoType = AmmoType.Battery,

        BatteryDepletionMin = 2,
        BatteryDepletionMax = 3,
        ShotsDeplete = 10,

        HeatRate = 5,
        CoolTime = 1.5,
        CoolWait = 1,
    } :: WeaponStats_T,
} :: {[string]: WeaponStats_T}