return {
    ["INVI-C"] = {	
		name						= "INVI-C",
		fullname					= "Personal Cloaking Device",		
		category					= "Suit module",
		description					= "The Invisibility Cloak harness is a special device mounted to the lower armor of a trooper. The device consists of a complex of advanced distortion technology which block a person?s electromagnetic profile, rendering them nearly invisible for a time. It is to be noted that a weapons discharge is enough to overload the device, resulting in the cloak field dropping.",
		quickdesc 					= "Near Invisibility",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = true, ["damage"] = true, ["sitting"] = false },
				
		energydeplete				= 2,
		energyregen					= 1,
		energymin					= 20
	},
	["SH3L-S"] = {	
		name						= "SH3L-S",
		fullname					= "Medical Nanite Dispenser",		
		category					= "Suit module",
		description					= "The Self Heal System is a special implant mounted in close proximity to the heart, lungs and other vital organs of a trooper. When the trooper is physically damaged by enemy fire, the device can be activated, sending a stream of healing nanites directly through the bloodstream to damaged areas.",
		quickdesc					= "Self Healing",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
		
		Holster						= "TorsoModule",
		
		trigger						= "Hold",
		
		restrictions				= { ["firing"] = false, ["damage"] = true, ["sitting"] = false },
		
		heal						= 5,
		rate						= .3,
		
		energydeplete				= 3,
		energyregen					= 2,
		energymin					= 40
	},
	["ENHC-S"] = {	
		name						= "ENHC-S",
		fullname					= "Shield Overcharger", 		
		category					= "Suit module",
		description					= "The Enhanced Capacitor Shield harness is a special device which is fitted over the normal armor of a trooper. The device consists of a shield overcharge matrix which hooks into shield implants and armor-based shield generators, and holds a capacitor which when activated, feeds a constant overcharge into the wearer's shield systems.",
		quickdesc					= "Damage Resistance",
		defaultcost					= 1000,		
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = false },
		
		walkspeedreduce				= 2,		
		damagenerf					= 0.5,
		
		energydeplete				= 2,
		energyregen					= 2,
		energymin					= 20
	},
	["FIEL-X"] = {	
		name						= "FIEL-X",
		fullname					= "Shock Field Generator",
		category					= "Suit module",
		quickdesc					= "Area Damage",		
		description					= "The Field Generator X is a special harness mounted to one of the arms, or other relevant appendages, of a trooper. Upon activation, the device effectively amplifies the wearer?s arm strength by a large factor by generating a phased energy field around it.",
		defaultcost					= 1000,
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "RightArmModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		damage						= 60,
		calcDamage = function(damage, distance)
			return math.clamp(damage * (10/distance), 0, 60)
		end,
		vehiclemultiplier			= 2,
		
		explosion					= {
									BlastRadius = 15		
		},
		
		energydeplete				= 100,
		energyregen					= 3,
		energymin					= 99
	},
	["HEAL-X"] = {	
		name						= "HEAL-X",
		fullname					= "Heal Field Generator",
		category					= "Suit module",
		quickdesc					= "Area Healing",		
		description					= "The Heal Generator X is a special harness mounted to one of the arms, or other relevant appendages, of a trooper. Upon activation, the device effectively amplifies the wearer?s arm strength by a large factor by generating a phased energy field around it that heals his teammates.",
		defaultcost					= 1000,
		cost						= 1000,
		slot						= 4,
		action						= "Heal",
		teamkill					= true,
		defaultlocked 				= false,
				
		Holster						= "RightArmModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		damage						= -60,
		calcDamage = function(damage, distance)
			return -math.clamp(-damage * (10/distance), 0, -damage)
		end,
		vehiclemultiplier			= 2,
		
		explosion					= {
									BlastRadius = 20		
		},
		
		energydeplete				= 100,
		energyregen					= 3,
		energymin					= 99
	},
	["APS"] = {	
		name						= "APS",
		fullname					= "Active Protection System",		
		category					= "Suit module",
		description					= "The ?APS? deflector screen projection harness is a special device manufactured by a less mentally stable sect of GORIUS Armories engineers. The APS, when activated, deploys a projected barrier covering the front arc of the trooper using it.",
		quickdesc					= "Shot Blocking Shield",
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		rate						= 0.5,
		
		energydeplete				= 2,
		energyregen					= 2,
		energymin					= 30
	},
	
	["SP0T-R"] = {	
		name						= "SP0T-R",
		fullname					= "Hostile Detection Module",		
		category					= "Suit module",
		description					= "The Spotter is a high sensitivity telemetry and sensing package which conveniently mounts onto the arm of a reconnaissance unit. When activated the device sends forth a wave of deep penetrating scans on variable frequencies, permitting the user to spot enemies who are hidden behind cover or concealment.",
		quickdesc					= "Hostile Marking",
		defaultcost					= 1000,		
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "LeftArmModule",
		
		trigger						= "Hold",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = false },
		
		rate						= 0.5,
		
		energydeplete				= 100,
		energyregen					= 1,
		energymin					= 99
	},

	["JET-P"] = {	
		name						= "JET-P",
		fullname					= "Vertical Boost Jets",
		category					= "Suit module",
		description					= "The Jet Pack is a special harness mounted to the back of the normal armor of a trooper. Two heavy duty fusion thrusters direct plasma and permit a soldier to fly far over a battlefield and eventually land safely, granting them a significant tactical advantage over hostiles in the area.",
		quickdesc					= "Fast Vertical Boost, Limited Mobility",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Hold",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		rate						= .3,
		
		energydeplete				= 12,
		energyregen					= 3,
		energymin					= 12,
	},

	["D0DG-P"] = {	
		name						= "D0DG-P",
		fullname					= "Horizontal Boost Jets",		
		category					= "Suit module",
		description					= "The Dodge Pack is a special harness mounted to the back of the normal armor of a trooper. Two lightweight fusion thrusters direct plasma and permit a soldier to dash far more quickly than simply sprinting would permit, allowing a soldier to quickly maneuver out of harm?s way, or into a stronger tactical position.",
		quickdesc					= "Strong Horizontal Boost",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		energydeplete				= 100,
		energyregen					= 3,
		energymin					= 99
	},

	["TEST"] = {	
		name						= "TEST",
		fullname					= "TEST Boost Jets",		
		category					= "TEST module",
		description					= "The TEST Pack is a TEST harness TEST to the TEST of the TEST armor of a TEST. Two lightweight fusion thrusters direct plasma and permit a soldier to dash far more quickly than simply sprinting would permit, allowing a soldier to quickly maneuver out of harm?s way, or into a stronger tactical position.",
		quickdesc					= "TEST Horizontal Boost",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		energydeplete				= 100,
		energyregen					= 3,
		energymin					= 99
	},
	["NJ-CT"] = {	
		name						= "NJ-CT",
		fullname					= "Matter manipulator",		
		category					= "Suit module",
		description					= "Developed by Gorius Armories for the WIJ Officer Council.",
		quickdesc					= "?",
		defaultcost					= 10000,		
		cost						= 10000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
 		energydeplete				= .2,
		energyregen					= 10,
		energymin					= 2
	},
	
	["OVER-C"] = {	
		name						= "OVER-C",
		fullname					= "Weapon overclocker",		
		category					= "Suit module",
		description					= "The OVER-Clocker is a compact module that is capable of, in a sense, 'overclocking' a weapon's phaser coils by overloading them to a near-critical state. The subsequently volatile plasma reaction significantly boosts the weapon's fire rate and phaser output, but sacrifices a large amount of accuracy due to the sheer recoil caused. Additionally, this reaction also puts much greater strain on the weapon's battery, draining it and overheating significantly faster than it's usual state. As such, the OVER-C is not intended to be used conventionally on a frequent basis, only when the moment calls for it.",
		quickdesc					= "Weapon overclocker",	
		defaultcost					= 1000,	
		cost						= 1000,
		slot						= 4,
		defaultlocked 				= false,
				
		Holster						= "TorsoModule",
		
		trigger						= "Press",
		
		restrictions				= { ["firing"] = false, ["damage"] = false, ["sitting"] = true },
		
		energydeplete				= 5,
		energyregen					= 2,
		energymin					= 10
	},
}