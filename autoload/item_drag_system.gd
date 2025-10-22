# ItemDragSystem.gd
extends Node

signal item_picked_up(item_data, source)
signal item_dropped()
signal item_returned()

var held_item_data = null
var held_item_source = null

func is_holding_item() -> bool:
	return held_item_data != null

func pick_up_item(item_data: Dictionary, source: Dictionary) -> void:
	if is_holding_item():
		push_warning("Trying to pick up item while already holding one")
		return
	
	held_item_data = item_data
	held_item_source = source
	DragPreview.show_preview(item_data["item"].icon, Vector2(64, 64))
	emit_signal("item_picked_up", item_data, source)

func drop_item() -> void:
	if not is_holding_item():
		return
		
	held_item_data = null
	held_item_source = null
	DragPreview.hide_preview()
	emit_signal("item_dropped")

func return_item_to_source() -> void:
	"""Return the held item back to where it came from (e.g., when UI closes)"""
	if not is_holding_item():
		return
	
	var source = held_item_source
	var data = held_item_data
	
	# Clear held state first
	held_item_data = null
	held_item_source = null
	DragPreview.hide_preview()
	
	emit_signal("item_returned")
	
	# Return to source based on type
	match source["type"]:
		"inventory":
			var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
			if inventory_ui and inventory_ui.inventory:
				# Item is already in the inventory at source["slot"], just refresh UI
				pass
		"equipment":
			var player = get_tree().get_first_node_in_group("player")
			if player:
				var equipment_manager = player.get_node_or_null("EquipmentManager")
				if equipment_manager:
					equipment_manager.equip_item(data["item"])

func cancel() -> void:
	"""Cancel the drag operation and return item to source"""
	return_item_to_source()

func get_held_item():
	return held_item_data

func get_held_source():
	return held_item_source
