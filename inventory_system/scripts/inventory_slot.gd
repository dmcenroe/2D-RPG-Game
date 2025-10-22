# inventory_slot.gd
extends PanelContainer

signal slot_hovered(item: Item)
signal slot_unhovered

@onready var margin_container = $MarginContainer
@onready var item_icon = $MarginContainer/ItemIcon
@onready var quantity_label = $MarginContainer/QuantityLabel

var slot_data = null
var slot_index: int = -1
var is_hovered: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

func set_slot_data(data, index: int = -1) -> void:
	slot_data = data
	slot_index = index
	update_display()
	
	# Check if mouse is currently over this slot
	if is_hovered and slot_data != null and slot_data["item"] != null:
		slot_hovered.emit(slot_data["item"])

func update_display() -> void:
	if slot_data == null or slot_data["item"] == null:
		item_icon.texture = null
		quantity_label.hide()
	else:
		item_icon.texture = slot_data["item"].icon
		if slot_data["quantity"] > 1:
			quantity_label.text = str(slot_data["quantity"])
			quantity_label.show()
		else:
			quantity_label.hide()

func _gui_input(event: InputEvent) -> void:
	# Handle clicks
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().get_first_node_in_group("inventory_ui").slot_clicked(slot_index)
	
	# Handle mouse motion for tooltip
	if event is InputEventMouseMotion:
		if not is_hovered:
			is_hovered = true
			if slot_data != null and slot_data["item"] != null:
				slot_hovered.emit(slot_data["item"])

func _get_drag_data(_at_position: Vector2):
	if slot_data == null or slot_data["item"] == null:
		return null
	
	print("Starting drag from inventory")
	
	# ONLY use manual preview - DON'T call set_drag_preview!
	DragPreview.show_preview(slot_data["item"].icon, Vector2(64, 64))
	slot_unhovered.emit()
	
	# Return data but NO set_drag_preview call
	return {
		"type": "item",
		"item": slot_data["item"],
		"source": "inventory",
		"source_slot": slot_index,
		"quantity": slot_data["quantity"]
	}

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		if is_hovered:
			is_hovered = false
			slot_unhovered.emit()
	
	elif what == NOTIFICATION_DRAG_END:
		modulate = Color.WHITE
		DragPreview.hide_preview()
	

func _can_drop_data(_at_position: Vector2, data) -> bool:
	# Check if the dropped data is valid
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	if not data.has("type") or data["type"] != "item":
		return false
	
	if not data.has("item"):
		return false
	
	# Accept drops from inventory or character sheet
	var source = data.get("source", "")
	if source == "inventory" or source == "character_sheet":
		# Visual feedback: highlight this slot
		modulate = Color(0.8, 1.0, 0.8)  # Greenish tint
		return true
	
	return false

func _drop_data(_at_position: Vector2, data) -> void:
	# Reset visual feedback
	modulate = Color.WHITE
	
	if typeof(data) != TYPE_DICTIONARY:
		return
	
	var source = data.get("source", "")
	
	if source == "inventory":
		# Swapping within inventory
		var from_slot = data.get("source_slot", -1)
		if from_slot != -1 and from_slot != slot_index:
			var inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
			if inventory_ui:
				inventory_ui.swap_slots(from_slot, slot_index)
	
	elif source == "character_sheet":
		# Unequipping from character sheet to inventory
		var item = data.get("item")
		var equipment_slot = data.get("equipment_slot")
		
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var equipment_manager = player.get_node_or_null("EquipmentManager")
			var inventory = player.get_node_or_null("Inventory")
			
			if equipment_manager and inventory:
				# Unequip from character sheet
				equipment_manager.unequip_item(equipment_slot)
				
				# Add to this inventory slot
				# If slot is empty, add here
				if slot_data == null or slot_data["item"] == null:
					inventory.add_item_to_slot(item, 1, slot_index)
				else:
					# Slot occupied - just add to inventory (it will find a spot)
					inventory.add_item(item, 1)
