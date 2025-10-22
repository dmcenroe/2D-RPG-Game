extends Resource
class_name LootSlot

@export var slot_name: String = "Loot Slot"
@export var entries: Array[SlotEntry] = []

# Validate that percentages add to 100%
func validate() -> bool:
	if Engine.is_editor_hint():
		return true
		
	if entries.is_empty():
		return true
	
	var total = 0.0
	for entry in entries:
		if entry:
			total += entry.drop_chance
	
	if abs(total - 100.0) > 0.01:
		push_warning("LootSlot '%s': Drop chances add to %.2f%% (should be 100%%)" % [slot_name, total])
		return false
	
	return true

# Roll this slot and return what dropped
func roll() -> Dictionary:
	if entries.is_empty():
		print("    [", slot_name, "] No entries configured")
		return {}
	
	var roll_value = randf() * 100.0
	var cumulative = 0.0
	
	for entry in entries:
		if not entry:
			continue
		
		cumulative += entry.drop_chance
		if roll_value <= cumulative:
			# Check if this is a "nothing" entry (null item)
			if entry.item == null:
				print("    [%s] Rolled %.2f%% → Nothing (%.1f%% chance)" % [slot_name, roll_value, entry.drop_chance])
				return {}
			
			var quantity = entry.get_quantity()
			print("    [%s] Rolled %.2f%% → %s x%d (%.1f%% chance)" % [slot_name, roll_value, entry.item.item_name, quantity, entry.drop_chance])
			
			return {
				"item": entry.item,
				"quantity": quantity
			}
	
	print("    [%s] ERROR: Roll fell through (%.2f%%)" % [slot_name, roll_value])
	return {}
