extends Resource
class_name SlotEntry

@export var item: Item
@export_range(0.0, 100.0, 0.1) var drop_chance: float = 0.0
@export var min_quantity: int = 1
@export var max_quantity: int = 1

func get_quantity() -> int:
	if min_quantity == max_quantity:
		return min_quantity
	return randi_range(min_quantity, max_quantity)
