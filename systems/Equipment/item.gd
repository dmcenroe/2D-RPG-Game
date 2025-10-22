# item.gd
extends Resource
class_name Item

enum ItemType {
	EQUIPMENT,
	MISC,
	QUEST,
	BAG
}

enum EquipmentSlot {
	NONE,           # For non-equipment items
	HEAD,
	CHEST,
	ARMS,
	HANDS,
	LEGS,
	FEET,
	PRIMARY,        # Main hand weapon
	SECONDARY,      # Off-hand / shield
	NECK,
	WAIST,
	WRIST,
	FINGER,         # Rings
	EAR,
	BACK,           # Cape/cloak
}

# === BASIC INFO ===
@export_group("Basic Info")
@export var item_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.EQUIPMENT

# === STACKING ===
@export_group("Stacking")
@export var max_stack_size: int = 1  # 1 = doesn't stack
@export var is_unique: bool = false

# === EQUIPMENT ===
@export_group("Equipment")
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE
@export var is_two_handed: bool = false

# === STATS (Equipment Only) ===
@export_group("Primary Stats")
@export var strength: int = 0
@export var intelligence: int = 0
@export var agility: int = 0
@export var dexterity: int = 0
@export var wisdom: int = 0
@export var stamina: int = 0
@export var charisma: int = 0

@export_group("Combat Stats")
@export var armor: int = 0
@export var damage: int = 0
@export var attack_speed: float = 0.0  # Modifier to attack speed

@export_group("Resistances")
@export var magic_resist: int = 0
@export var fire_resist: int = 0
@export var cold_resist: int = 0
@export var poison_resist: int = 0
@export var disease_resist: int = 0

# === BAG ===
@export_group("Bag")
@export var bag_slot_count: int = 0

# Get a formatted tooltip string
func get_tooltip() -> String:
	var tooltip = "[b]%s[/b]\n" % item_name
	
	if equipment_slot != EquipmentSlot.NONE:
		tooltip += "[color=gray]%s[/color]\n" % EquipmentSlot.keys()[equipment_slot]
	
	if description:
		tooltip += "\n%s\n" % description
	
	# Add stats if equipment
	if item_type == ItemType.EQUIPMENT:
		var has_stats = false
		
		# Primary stats
		if strength > 0: 
			tooltip += "\n[color=green]+%d STR[/color]" % strength
			has_stats = true
		if intelligence > 0: 
			tooltip += "\n[color=green]+%d INT[/color]" % intelligence
			has_stats = true
		if agility > 0: 
			tooltip += "\n[color=green]+%d AGI[/color]" % agility
			has_stats = true
		if dexterity > 0: 
			tooltip += "\n[color=green]+%d DEX[/color]" % dexterity
			has_stats = true
		if wisdom > 0: 
			tooltip += "\n[color=green]+%d WIS[/color]" % wisdom
			has_stats = true
		if stamina > 0: 
			tooltip += "\n[color=green]+%d STA[/color]" % stamina
			has_stats = true
		if charisma > 0: 
			tooltip += "\n[color=green]+%d CHA[/color]" % charisma
			has_stats = true
		
		# Combat stats
		if armor > 0:
			tooltip += "\n[color=cyan]+%d Armor[/color]" % armor
			has_stats = true
		if damage > 0:
			tooltip += "\n[color=red]+%d Damage[/color]" % damage
			has_stats = true
	
	return tooltip
