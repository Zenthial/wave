export type Inventory = {
    Weapons: {string},
    Gadgets: {string},
    Skills: {string}
}


local DEFAULT_LOADOUT = {
    Primary = "X11",

    Secondary = "Y14",

    Gadget = "NDG",

    Skill = "FIEL-X",
}

return DEFAULT_LOADOUT