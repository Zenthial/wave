local Holsters = {
    Back = "Back",
    TorsoModule = "TorsoModule",
    Hip = "Hip",
    RightArmModule = "RightArmModule",
    LeftArmModule = "LeftArmModule",
    Melee = "Melee"
}

return {
	Name = "BL1N-K",
	FullName = "Horizontal Teleportation",
	Category = "Suit module",
	Description = "The BL1N-K allows the user to zip horizontally through space in the direction they are moving. Stores up to three charges of the blink ability and generates more every few seconds.",
	QuickDescription = "Short Teleportation",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
    Distance = 30,
	Holster = Holsters.TorsoModule,
	Trigger = "Press",
	EnergyDeplete = 33,
	EnergyRegen = 2,
	EnergyMin = 50,
}
