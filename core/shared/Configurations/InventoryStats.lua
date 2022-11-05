export type Inventory = {
    Weapons: {string},
    Gadgets: {string},
    Skills: {string}
}


local DEFAULT_LOADOUT = {
    Primary = "W17",

    Secondary = "Y14",

    Gadget = "NDG",

    Skill = "POIS-N",
}

return DEFAULT_LOADOUT