# inventory_ui.gd
extends Control

@onready var grid_container = $InventoryPanel/MarginContainer/VBoxContainer/GridContainer

@export var inventory: Inventory
@export var slot_scene: PackedScene

var tooltip_label: Label = null

func _ready() -> void:
	add_to_group("inventory_ui")
	
	if inventory == null:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			inventory = player.get_node("Inventory")
	
	hide()
	
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		populate_slots()
	
	# Setup tooltip
	var tooltip_panel = PanelContainer.new()
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.hide()
	add_child(tooltip_panel)
	
	tooltip_label = Label.new()
	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	tooltip_panel.add_child(tooltip_label)
	tooltip_label.set_meta("panel", tooltip_panel)
	
	# Connect to ItemDragSystem signals
	ItemDragSystem.item_dropped.connect(_on_inventory_changed)
	ItemDragSystem.item_returned.connect(_on_inventory_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_bags"):
		toggle_visibility()
	elif event.is_action_pressed("ui_cancel") and ItemDragSystem.is_holding_item():
		# ESC to cancel drag
		var source = ItemDragSystem.get_held_source()
		if source and source["type"] == "inventory":
			ItemDragSystem.return_item_to_source()

func toggle_visibility() -> void:
	visible = !visible
	
	# If closing while holding an item, return it to source
	if not visible and ItemDragSystem.is_holding_item():
		var source = ItemDragSystem.get_held_source()
		if source and source["type"] == "inventory":
			ItemDragSystem.return_item_to_source()
		hide_tooltip()

func _process(_delta: float) -> void:
	# Update tooltip position
	var tooltip_panel = tooltip_label.get_meta("panel")
	if tooltip_panel.visible:
		tooltip_panel.global_position = get_global_mouse_position() + Vector2(15, 15)

func populate_slots() -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for i in range(inventory.max_slots):
		var slot = slot_scene.instantiate()
		grid_container.add_child(slot)
		slot.set_slot_data(inventory.get_item_at_slot(i), i)
		slot.slot_hovered.connect(show_tooltip)
		slot.slot_unhovered.connect(hide_tooltip)

func _on_inventory_changed() -> void:
	var slots = grid_container.get_children()
	for i in range(slots.size()):
		# Check if this slot is being held
		var is_held_slot = false
		if ItemDragSystem.is_holding_item():
			var source = ItemDragSystem.get_held_source()
			if source and source["type"] == "inventory" and source["slot"] == i:
				is_held_slot = true
		
		if is_held_slot:
			slots[i].set_slot_data(null, i)
		else:
			slots[i].set_slot_data(inventory.get_item_at_slot(i), i)

func slot_clicked(slot_index: int) -> void:
	if not ItemDragSystem.is_holding_item():
		# Pick up item
		var slot_data = inventory.get_item_at_slot(slot_index)
		if slot_data != null and slot_data["item"] != null:
			ItemDragSystem.pick_up_item(slot_data, {
				"type": "inventory",
				"slot": slot_index
			})
			
			var slots = grid_container.get_children()
			slots[slot_index].set_slot_data(null, slot_index)
			hide_tooltip()
	else:
		# Drop item
		var source = ItemDragSystem.get_held_source()
		
		if source["type"] == "inventory":
			# Swapping within inventory
			if source["slot"] != slot_index:
				inventory.swap_slots(source["slot"], slot_index)
			ItemDragSystem.drop_item()
		elif source["type"] == "equipment":
			# Dropping equipment into inventory
			var held_data = ItemDragSystem.get_held_item()
			var target_slot_data = inventory.get_item_at_slot(slot_index)
			
			# If target slot has an item that can be equipped, swap
			if target_slot_data and target_slot_data["item"] != null:
				var target_item = target_slot_data["item"]
				if target_item.equipment_slot == source["slot"]:
					# Swap: equip target item, put held item in this slot
					inventory.set_item_at_slot(slot_index, held_data["item"], held_data.get("quantity", 1))
					
					var player = get_tree().get_first_node_in_group("player")
					if player:
						var equipment_manager = player.get_node_or_null("EquipmentManager")
						if equipment_manager:
							equipment_manager.equip_item(target_item)
					
					ItemDragSystem.drop_item()
					return
			
			# Otherwise just place item in slot
			inventory.set_item_at_slot(slot_index, held_data["item"], held_data.get("quantity", 1))
			ItemDragSystem.drop_item()

func show_tooltip(item: Item) -> void:
	if not ItemDragSystem.is_holding_item():
		tooltip_label.text = item.item_name
		var tooltip_panel = tooltip_label.get_meta("panel")
		tooltip_panel.show()

func hide_tooltip() -> void:
	var tooltip_panel = tooltip_label.get_meta("panel")
	tooltip_panel.hide()
