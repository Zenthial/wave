export type AnimationTreeStruct = {
    Equipping: number, -- 0 = not equipping, 1 = equipping, -1 = unequipping
    
    SprintActive: boolean,
    SprintPlaying: boolean,

    Rolling: boolean,

    CrouchActive: boolean,
    CrouchPlaying: boolean,

    ReloadActive: boolean,
    ReloadPlaying: boolean,

    WeaponEquipped: boolean,
    WeaponName: boolean
}

return {}