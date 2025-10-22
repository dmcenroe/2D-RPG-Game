# inventory.gd
extends Node
class_name Inventory

signal inventory_changed
signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
@export var rusty_dagger: Item

@export var max_slots: int = 12

var items: Array = []

func _ready() -> void:
	items.resize(max_slots)
	add_item(rusty_dagger, 1)

func add_item(item: Item, quantity: int = 1) -> bool:
	if item == null:
		return false
	
	if item.is_unique and has_item(item):
		print("Cannot add unique item - already in inventory")
		return false
	
	if item.max_stack_size > 1:
		for i in range(items.size()):
			if items[i] != null and items[i]["item"] == item:
				var current_quantity = items[i]["quantity"]
				if current_quantity < item.max_stack_size:
					var space_left = item.max_stack_size - current_quantity
					var amount_to_add = min(quantity, space_left)
					items[i]["quantity"] += amount_to_add
					quantity -= amount_to_add
					inventory_changed.emit()
					item_added.emit(item, amount_to_add)
					
					if quantity <= 0:
						return true
	
	while quantity > 0:
		var empty_slot = find_empty_slot()
		if empty_slot == -1:
			print("Inventory full!")
			return false
		
		var amount_to_add = min(quantity, item.max_stack_size)
		items[empty_slot] = {"item": item, "quantity": amount_to_add}
		quantity -= amount_to_add
		inventory_changed.emit()
		item_added.emit(item, amount_to_add)
	
	return true

func remove_item(item: Item, quantity: int = 1) -> bool:
	for i in range(items.size()):
		if items[i] != null and items[i]["item"] == item:
			if items[i]["quantity"] >= quantity:
				items[i]["quantity"] -= quantity
				if items[i]["quantity"] <= 0:
					items[i] = null
				inventory_changed.emit()
				item_removed.emit(item, quantity)
				return true
	return false

func has_item(item: Item) -> bool:
	for slot in items:
		if slot != null and slot["item"] == item:
			return true
	return false

func find_empty_slot() -> int:
	for i in range(items.size()):
		if items[i] == null:
			return i
	return -1

func get_item_at_slot(slot_index: int):
	if slot_index >= 0 and slot_index < items.size():
		return items[slot_index]
	return null

func swap_slots(from_index: int, to_index: int) -> void:
	if from_index < 0 or from_index >= items.size():
		return
	if to_index < 0 or to_index >= items.size():
		return
	
	# Swap the items
	var temp = items[from_index]
	items[from_index] = items[to_index]
	items[to_index] = temp
	
	inventory_changed.emit()


func add_item_to_slot(slot_index: int, item: Item, quantity: int) -> bool:
	if slot_index < 0 or slot_index >= max_slots:
		return false
	
	if item == null:
		return false
	
	# If slot is empty, add item there
	if items[slot_index] == null:
		items[slot_index] = {"item": item, "quantity": quantity}
		inventory_changed.emit()
		item_added.emit(item, quantity)
		return true
	else:
		# Slot occupied - if same item and stackable, try to add to stack
		var existing = items[slot_index]
		if existing["item"] == item and item.max_stack_size > 1:
			var space_left = item.max_stack_size - existing["quantity"]
			var amount_to_add = min(quantity, space_left)
			if amount_to_add > 0:
				existing["quantity"] += amount_to_add
				inventory_changed.emit()
				item_added.emit(item, amount_to_add)
				return true
		
		# Can't add to this slot, use normal add_item
		return add_item(item, quantity)

func set_item_at_slot(slot_index: int, item: Item, quantity: int) -> void:
	if slot_index < 0 or slot_index >= max_slots:
		return
	
	var old_item = items[slot_index]
	
	if item == null or quantity <= 0:
		# Clear the slot
		items[slot_index] = null
	else:
		items[slot_index] = {"item": item, "quantity": quantity}
	
	inventory_changed.emit()
	
	if old_item:
		item_removed.emit(old_item["item"], old_item["quantity"])
	if item:
		item_added.emit(item, quantity)

func remove_item_at_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= items.size():
		return false
	
	if items[slot_index] == null:
		return false
	
	var removed_item = items[slot_index]
	items[slot_index] = null
	inventory_changed.emit()
	item_removed.emit(removed_item["item"], removed_item["quantity"])
	return true

func clear_slot(slot_index: int) -> void:
	set_item_at_slot(slot_index, null, 0)
