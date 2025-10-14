# inventory_ui.gd
extends Control

@onready var grid_container = $InventoryPanel/MarginContainer/VBoxContainer/GridContainer

@export var inventory: Inventory
@export var slot_scene: PackedScene

var held_item_index: int = -1
var held_item_preview: TextureRect = null
var tooltip_label: Label = null

func _ready() -> void:
	add_to_group("inventory_ui")
	
	if inventory == null:
		var player = get_tree().get_first_node_in_group("player")
		if player:
			inventory = player.get_node("Inventory")
	
	# Start hidden
	hide()
	
	if inventory:
		inventory.inventory_changed.connect(_on_inventory_changed)
		populate_slots()
	
	held_item_preview = TextureRect.new()
	held_item_preview.custom_minimum_size = Vector2(64, 64)
	held_item_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	held_item_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	held_item_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	held_item_preview.hide()
	add_child(held_item_preview)
	
	var tooltip_panel = PanelContainer.new()
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.hide()
	add_child(tooltip_panel)
	
	tooltip_label = Label.new()
	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	tooltip_panel.add_child(tooltip_label)
	
	tooltip_label.set_meta("panel", tooltip_panel)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_bags"):
		toggle_visibility()

func toggle_visibility() -> void:
	visible = !visible
	
	# If closing while holding an item, put it back
	if not visible and held_item_index != -1:
		held_item_index = -1
		held_item_preview.hide()
		hide_tooltip()
		_on_inventory_changed()

func _process(delta: float) -> void:
	if held_item_preview.visible:
		held_item_preview.global_position = get_global_mouse_position() - held_item_preview.size / 2
	
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
		if i == held_item_index:
			slots[i].set_slot_data(null, i)
		else:
			slots[i].set_slot_data(inventory.get_item_at_slot(i), i)

func slot_clicked(slot_index: int) -> void:
	if held_item_index == -1:
		var slot_data = inventory.get_item_at_slot(slot_index)
		if slot_data != null and slot_data["item"] != null:
			held_item_index = slot_index
			held_item_preview.texture = slot_data["item"].icon
			held_item_preview.show()
			
			var slots = grid_container.get_children()
			slots[slot_index].set_slot_data(null, slot_index)
			
			hide_tooltip()
	else:
		if held_item_index != slot_index:
			inventory.swap_slots(held_item_index, slot_index)
		held_item_index = -1
		held_item_preview.hide()
		_on_inventory_changed()

func swap_slots(from_index: int, to_index: int) -> void:
	inventory.swap_slots(from_index, to_index)

func show_tooltip(item: Item) -> void:
	if held_item_index == -1:
		tooltip_label.text = item.item_name
		var tooltip_panel = tooltip_label.get_meta("panel")
		tooltip_panel.show()

func hide_tooltip() -> void:
	var tooltip_panel = tooltip_label.get_meta("panel")
	tooltip_panel.hide()
