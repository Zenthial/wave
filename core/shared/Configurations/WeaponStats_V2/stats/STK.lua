return {
	Name = "STK",
	FullName = "Sticky Plasma Grenade",
	Category = "Grenade",
	Description = "The Sticky Nadion Detonation Grenade is a modified version of the standard explosive grenade issued to WIJ forces. It has very simple and easy to use code keys which ensure proper usage of the ordnance. Upon being thrown the grenade, the grenade sticks to the first surface it hits. It then begins a nadion cascade reaction, which results in a small explosion once it goes off.",
	QuickDescription = "Explosive",
	WeaponCost = 2550,
	Slot = 3,
	Type = "Projectile",
	CanTeamKill = false,
	Locked = false,
	Damage = 50,
	CalculateDamage = function(damage, distance)
		damage = damage + (250 /distance)
		return math.clamp(damage, 50, 75)
	end,
	VehicleMultiplier = 4,
	BlastRadius = 15,
}
