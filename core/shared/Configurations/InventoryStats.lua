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
        "C0S"
    },

    Skills = {
        "D0DG-P"
    }
}

return DEFAULT_LOADOUT