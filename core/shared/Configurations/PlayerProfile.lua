export type PlayerProfile_T = {
    Options: {
        LowDetail: boolean,
        NoMaterials: boolean,
        ShowHolsteredWeapons: boolean,
        Shadows: boolean,
        Particles: boolean,
        BulletHoles: boolean,
    },
}

local PlayerProfile = {
    Options = {
        LowDetail = false,
        NoMaterials = false,
        ShowHolsteredWeapons = true,
        Shadows = true,
        Particles = true,
        BulletHoles = true,
    },

    Stats = {
        Kills = 0,
        Deaths = 0,
        Assists = 0,

        HeadshotKills = 0,

        Damage = 0,
        Heals = 0,

        Marksman = 0,
        Revenge = 0,
        CloseCalls = 0,

        DoubleKills = 0,
        TripleKills = 0,
        QuadKills = 0,
        Rampage = 0,
        Savage = 0,
        NoMercy = 0,
        Easy = 0,
        NotEvenTryin = 0,
        YouGottaCalmDown = 0,
        CallThePopo = 0,
        Bye = 0,
        SystemUnavailable = 0,

        DeployableKills = 0,
        DeployablesPlaced = 0,
        DeployablesDestroyed = 0,

        HighestKillingSpree = 0,
        MostKills = 0,
        TimePlayed = 0,
    },

    WeaponSpecificStats = {}
}

return PlayerProfile