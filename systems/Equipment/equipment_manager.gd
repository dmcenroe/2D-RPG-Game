# equipment_manager.gd
# Create at: res://systems/equipment/equipment_manager.gd
extends Node
class_name EquipmentManager

signal equipment_changed(slot: Item.EquipmentSlot, item: Item)

# Dictionary mapping slot enum to equipped item
var equipped_items: Dictionary = {}

func _ready() -> void:
	# Initialize all slots as empty
	for slot in Item.EquipmentSlot.values():
		equipped_items[slot] = null

# Equip an item to its appropriate slot
func equip_item(item: Item) -> bool:
	if not item or item.equipment_slot == Item.EquipmentSlot.NONE:
		print("Cannot equip: Item has no equipment slot")
		return false
	
	var slot = item.equipment_slot
	
	# Handle two-handed weapons
	if item.is_two_handed:
		# Check if secondary slot is occupied
		if equipped_items[Item.EquipmentSlot.SECONDARY] != null:
			print("Cannot equip two-handed weapon: Off-hand occupied")
			return false
	
	# If slot is occupied, unequip current item first
	if equipped_items[slot] != null:
		unequip_item(slot)
	
	# Equip the new item
	equipped_items[slot] = item
	equipment_changed.emit(slot, item)
	print("Equipped: ", item.item_name, " to ", Item.EquipmentSlot.keys()[slot])
	return true

# Unequip item from a slot
func unequip_item(slot: Item.EquipmentSlot) -> Item:
	var item = equipped_items[slot]
	if item == null:
		return null
	
	equipped_items[slot] = null
	equipment_changed.emit(slot, null)
	print("Unequipped: ", item.item_name)
	return item

# Get item in a specific slot
func get_equipped_item(slot: Item.EquipmentSlot) -> Item:
	return equipped_items.get(slot, null)

# Check if a slot is empty
func is_slot_empty(slot: Item.EquipmentSlot) -> bool:
	return equipped_items.get(slot, null) == null

# Get all equipped items as an array
func get_all_equipped() -> Array[Item]:
	var items: Array[Item] = []
	for slot in equipped_items.values():
		if slot != null:
			items.append(slot)
	return items

# Calculate total stat bonuses from all equipped items
func get_total_stat_bonus(stat_name: String) -> int:
	var total = 0
	# TODO: Add item stat bonuses when we add them to Item resource
	return total
