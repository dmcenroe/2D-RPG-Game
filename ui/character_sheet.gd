# character_sheet.gd
extends Control

@onready var player = get_tree().get_first_node_in_group("player")
@onready var equipment_manager: EquipmentManager = null

# Character Info Labels
@onready var name_label = $Panel/MarginContainer/VBox/CharacterInfo/NameLabel
@onready var class_label = $Panel/MarginContainer/VBox/CharacterInfo/ClassLabel
@onready var race_label = $Panel/MarginContainer/VBox/CharacterInfo/RaceLabel
@onready var level_label = $Panel/MarginContainer/VBox/CharacterInfo/LevelLabel

# Stat Labels
@onready var str_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/StregnthValue
@onready var int_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/IntelligenceValue
@onready var agi_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/AgilityValue
@onready var dex_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/DexterityValue
@onready var wis_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/WisdomValue
@onready var sta_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/StaminaValue
@onready var cha_label = $Panel/MarginContainer/VBox/StatsPanel/MarginContainer/VBox/StatsGrid/CharismaValue

# Window state
var is_open: bool = false
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Equipment Slots
var equipment_slots: Dictionary = {}

func _ready() -> void:
	# Start hidden
	hide()
	is_open = false
	
	# FIX: Let mouse clicks pass through empty space
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add StyleBox to Panel for visibility
	if has_node("Panel"):
		var panel = $Panel
		
		# Panel BLOCKS clicks (so you can interact with UI)
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = Color(0.2, 0.2, 0.25, 0.95)
		stylebox.border_width_left = 2
		stylebox.border_width_top = 2
		stylebox.border_width_right = 2
		stylebox.border_width_bottom = 2
		stylebox.border_color = Color(0.4, 0.4, 0.5)
		panel.add_theme_stylebox_override("panel", stylebox)
		
		# Connect dragging
		panel.gui_input.connect(_on_panel_gui_input)
	
	# Connect to player
	if player:
		equipment_manager = player.get_node_or_null("EquipmentManager")
		if equipment_manager:
			equipment_manager.equipment_changed.connect(_on_equipment_changed)
	
	# Setup equipment slots
	setup_equipment_slots()
	
	# Connect to ItemDragSystem signals
	ItemDragSystem.item_dropped.connect(_on_item_drag_system_changed)
	ItemDragSystem.item_returned.connect(_on_item_drag_system_changed)
	
	# DEBUG: Check CanvasLayer
	var canvas_layer = get_parent()
	if canvas_layer is CanvasLayer:
		print("CharacterSheet CanvasLayer layer: ", canvas_layer.layer)

func _input(event: InputEvent) -> void:
	# Toggle character sheet
	if event.is_action_pressed("toggle_character"):
		toggle_visibility()
	
	# ESC to cancel drag if item is from equipment
	if event.is_action_pressed("ui_cancel") and ItemDragSystem.is_holding_item():
		var source = ItemDragSystem.get_held_source()
		if source and source["type"] == "equipment":
			ItemDragSystem.return_item_to_source()
	
	# Handle window dragging
	if is_dragging:
		if event is InputEventMouseMotion:
			position = event.position - drag_offset
		elif event is InputEventMouseButton and not event.pressed:
			is_dragging = false

func _on_panel_gui_input(event: InputEvent) -> void:
	# Drag window by clicking top area
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if event.position.y < 40:  # Header area only
				is_dragging = true
				drag_offset = event.position + $Panel.position
		else:
			is_dragging = false

func toggle_visibility() -> void:
	is_open = !is_open
	
	if is_open:
		call_deferred("_do_show")
	else:
		# If closing while holding an equipment item, return it
		if ItemDragSystem.is_holding_item():
			var source = ItemDragSystem.get_held_source()
			if source and source["type"] == "equipment":
				ItemDragSystem.return_item_to_source()
		hide()

func _do_show() -> void:
	# Reset anchors (prevent layout stretching)
	anchor_left = 0
	anchor_top = 0
	anchor_right = 0
	anchor_bottom = 0
	
	# Set size
	custom_minimum_size = Vector2(600, 500)
	
	# Center on screen
	var viewport_size = get_viewport().get_visible_rect().size
	position = (viewport_size - Vector2(600, 500)) / 2
	
	# Show with proper rendering settings
	show()
	modulate = Color.WHITE
	z_index = 1000
	
	# Ensure Panel is visible
	if has_node("Panel"):
		var panel = $Panel
		panel.show()
		panel.modulate = Color.WHITE
	
	# RECONNECT to equipment manager in case it wasn't ready before
	if player and not equipment_manager:
		equipment_manager = player.get_node_or_null("EquipmentManager")
		if equipment_manager:
			# Disconnect if already connected (avoid duplicates)
			if equipment_manager.equipment_changed.is_connected(_on_equipment_changed):
				equipment_manager.equipment_changed.disconnect(_on_equipment_changed)
			equipment_manager.equipment_changed.connect(_on_equipment_changed)
			print("Character sheet connected to equipment manager")
	
	# Update content after showing (deferred to avoid layout conflicts)
	call_deferred("_update_content")

func _update_content() -> void:
	update_character_info()
	update_stats()
	update_all_equipment_slots()

func setup_equipment_slots() -> void:
	var equipment_panel = $Panel/MarginContainer/VBox/EquipmentPanel/MarginContainer/VBox/EquipmentGrid
	
	for child in equipment_panel.get_children():
		if child.has_meta("equipment_slot"):
			var slot_type = child.get_meta("equipment_slot")
			equipment_slots[slot_type] = child
			
			# Connect click directly
			child.mouse_filter = Control.MOUSE_FILTER_STOP
			child.gui_input.connect(_on_equipment_slot_gui_input.bind(slot_type))

func _on_equipment_slot_gui_input(event: InputEvent, slot_type: Item.EquipmentSlot) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_equipment_slot_clicked(slot_type)

func update_character_info() -> void:
	if not player:
		return
	
	name_label.text = player.character_name
	class_label.text = "Class: " + player.character_class
	race_label.text = "Race: " + player.character_race
	level_label.text = "Level: " + str(player.character_level)

func update_stats() -> void:
	if not player:
		return
	
	# Base stats
	var total_str = player.strength
	var total_int = player.intelligence
	var total_agi = player.agility
	var total_dex = player.dexterity
	var total_wis = player.wisdom
	var total_sta = player.stamina
	var total_cha = player.charisma
	
	# Add equipment bonuses
	if equipment_manager:
		for item in equipment_manager.get_all_equipped():
			if item:
				total_str += item.strength
				total_int += item.intelligence
				total_agi += item.agility
				total_dex += item.dexterity
				total_wis += item.wisdom
				total_sta += item.stamina
				total_cha += item.charisma
	
	# Update labels (show bonus in green if any)
	str_label.text = format_stat_value(player.strength, total_str)
	int_label.text = format_stat_value(player.intelligence, total_int)
	agi_label.text = format_stat_value(player.agility, total_agi)
	dex_label.text = format_stat_value(player.dexterity, total_dex)
	wis_label.text = format_stat_value(player.wisdom, total_wis)
	sta_label.text = format_stat_value(player.stamina, total_sta)
	cha_label.text = format_stat_value(player.charisma, total_cha)

func format_stat_value(base: int, total: int) -> String:
	if total > base:
		return "%d [color=green](+%d)[/color]" % [total, total - base]
	else:
		return str(total)

func update_all_equipment_slots() -> void:
	if not equipment_manager:
		return
	
	for slot_type in equipment_slots.keys():
		var item = equipment_manager.get_equipped_item(slot_type)
		update_equipment_slot_display(slot_type, item)

func update_equipment_slot_display(slot_type: Item.EquipmentSlot, item: Item) -> void:
	if not equipment_slots.has(slot_type):
		return
	
	var slot_ui = equipment_slots[slot_type]
	
	# Check if this slot is currently being held
	var is_held = false
	if ItemDragSystem.is_holding_item():
		var source = ItemDragSystem.get_held_source()
		if source and source["type"] == "equipment" and source["slot"] == slot_type:
			is_held = true
	
	# ItemIcon is nested: SlotNode/VBox/ItemIcon
	if is_held:
		# Hide the icon if we're holding it
		if slot_ui.has_node("VBox/ItemIcon"):
			var icon_node = slot_ui.get_node("VBox/ItemIcon")
			icon_node.texture = null
	elif item:
		if slot_ui.has_node("VBox/ItemIcon"):
			var icon_node = slot_ui.get_node("VBox/ItemIcon")
			icon_node.texture = item.icon
			icon_node.show()
	else:
		if slot_ui.has_node("VBox/ItemIcon"):
			var icon_node = slot_ui.get_node("VBox/ItemIcon")
			icon_node.texture = null

func _on_equipment_changed(slot: Item.EquipmentSlot, item: Item) -> void:
	update_equipment_slot_display(slot, item)
	update_stats()

func _on_item_drag_system_changed() -> void:
	# Refresh all equipment slot displays when drag state changes
	update_all_equipment_slots()

func _on_equipment_slot_clicked(slot_type: Item.EquipmentSlot) -> void:
	if not equipment_manager:
		return
	
	if not ItemDragSystem.is_holding_item():
		# Pick up equipped item
		var item = equipment_manager.get_equipped_item(slot_type)
		if item:
			equipment_manager.unequip_item(slot_type)
			ItemDragSystem.pick_up_item({
				"item": item,
				"quantity": 1
			}, {
				"type": "equipment",
				"slot": slot_type
			})
			update_equipment_slot_display(slot_type, null)
	else:
		# Try to equip held item
		var held_data = ItemDragSystem.get_held_item()
		var held_item = held_data["item"]
		
		# Check if item can be equipped in this slot
		if held_item.equipment_slot == slot_type:
			var current_item = equipment_manager.get_equipped_item(slot_type)
			var source = ItemDragSystem.get_held_source()
			
			# Equip the new item
			equipment_manager.equip_item(held_item)
			
			# Handle the source (remove from inventory if it came from there)
			if source["type"] == "inventory":
				var player_inventory = player.get_node_or_null("Inventory")
				if player_inventory:
					player_inventory.remove_item_at_slot(source["slot"])
			
			# Handle swapped item (put it where the held item came from)
			if current_item:
				if source["type"] == "equipment":
					# Swap equipment slots
					equipment_manager.equip_item(current_item)
					# Note: the current_item will go to the source slot automatically
					# when we update the visual
				elif source["type"] == "inventory":
					# Put unequipped item into the inventory slot
					var player_inventory = player.get_node_or_null("Inventory")
					if player_inventory:
						player_inventory.set_item_at_slot(source["slot"], current_item, 1)
			
			ItemDragSystem.drop_item()
			update_equipment_slot_display(slot_type, held_item)
