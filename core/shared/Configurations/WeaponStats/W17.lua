return function(FireMode, BulletType, Bullets, Caches, AmmoType, Holsters, GunTypes, AnimationData)
    return {
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
end