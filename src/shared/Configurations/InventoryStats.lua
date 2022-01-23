export type Inventory = {
    Weapons: {string},
    Gadgets: {string},
    Skills: {string}
}


local DEFAULT_LOADOUT = {
    Weapons = {
        "W17",
    },

    Gadgets = {
        "NDG"
    },

    Skills = {
        "D0DG-P"
    }
}

return DEFAULT_LOADOUT