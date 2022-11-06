local Holsters = {
    Back = "Back",
    TorsoModule = "TorsoModule",
    Hip = "Hip",
    RightArmModule = "RightArmModule",
    LeftArmModule = "LeftArmModule",
    Melee = "Melee"
}

return {
	Name = "POIS-N",
	FullName = "Area Poison",
	Category = "Suit module",
	QuickDescription = "Area Damage and Healing",
	Description = "The POIS-N is a special harness mounted to one of the arms, or other relevant appendages, of a trooper. Upon activation, the device drains the life force of opposing forces, transferring that to friendly forces.",
	WeaponCost = 1000,
	Slot = 4,
	Locked = false,
	Holster = Holsters.LeftArmModule,
	Trigger = "Hold",
	Damage = 4,
    HealFactor = .25,
	VehicleMultiplier = 2,
	BlastRadius = 15,
	EnergyDeplete = 4,
	EnergyRegen = 3,
	EnergyMin = 99,
}
