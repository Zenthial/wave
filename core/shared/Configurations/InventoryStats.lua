export type Inventory = {
    Weapons: {string},
    Gadgets: {string},
    Skills: {string}
}


local DEFAULT_LOADOUT = {
    Primary = "W17",

    Secondary = "Y14",

    Gadget = "STK",

    Skill = "APS",
}

return DEFAULT_LOADOUT