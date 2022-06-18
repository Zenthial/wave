local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

if RunService:IsClient() then
    local BulletCaches = Instance.new("Folder")
    BulletCaches.Name = "BulletCaches"
    BulletCaches.Parent = workspace
end

local WeaponStats = {}

for _, file in pairs(script.stats:GetChildren()) do
    local mod = require(file)

    assert(mod.Name, "No name for " .. file.Name)

    WeaponStats[mod.Name] = mod
end

return WeaponStats