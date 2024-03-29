export type PlayerProfile_T = {
    Options: {
        LowDetail: boolean,
        NoMaterials: boolean,
        ShowHolsteredWeapons: boolean,
        Shadows: boolean,
        Particles: boolean,
        BulletHoles: boolean,
    },

    Keybinds: {
        Menu: string,
        Interact: string,
        Spot: string,
        Aim: string,
        Melee: string,
        Sprint: string,
        Crouch: string,
        Gadget: string,
        Skill: string,
        Chat: string,
        Leaderboard: string,
        ToggleDisplay: string,
        VehicleIgnition: string,
        VehicleInteract: string,
    },
}

export type WeaponStats_T = {
    Kills: number,
    Assists: number,
    Headshots: number,
    SecondsPlayed: number,
    GamesWon: number,
    Heals: number
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

    Keybinds = {
        Menu = "M",
        Interact = "E",
        Spot = "V",
        Aim = "Q",
        Melee = "R",
        Sprint = "LeftShift",
        Crouch = "C",
        Gadget = "G",
        Skill = "F",
        Chat = "Slash",
        Inventory = "B",
        Leaderboard = "Tab",
        ToggleDisplay = "LeftControl",
        VehicleIgnition = "Y",
        VehicleInteract = "P",
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
