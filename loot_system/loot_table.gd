extends Resource
class_name LootTable

@export var table_name: String = "Loot Table"
@export var loot_slots: Array[LootSlot] = []

# Roll all slots and return array of items that dropped
func roll_all() -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	
	for slot in loot_slots:
		if slot:
			var result = slot.roll()
			if result.size() > 0:
				drops.append(result)
	
	return drops

# Validate entire table
func validate() -> bool:
	var all_valid = true
	for slot in loot_slots:
		if slot and not slot.validate():
			all_valid = false
	return all_valid
