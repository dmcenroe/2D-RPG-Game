# item.gd
extends Resource
class_name Item

enum ItemType {
	EQUIPMENT,
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

@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var max_stack_size: int = 1  # 1 = doesn't stack, 99 = stackable to 99
@export var item_type: ItemType = ItemType.EQUIPMENT
@export var equipment_slot: EquipmentSlot = EquipmentSlot.NONE
@export var is_two_handed: bool = false
@export var is_unique: bool = false
@export var bag_slot_count: int
