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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().get_first_node_in_group("inventory_ui").slot_clicked(slot_index)
	
	if event is InputEventMouseMotion:
		if not is_hovered:
			is_hovered = true
			if slot_data != null and slot_data["item"] != null:
				slot_hovered.emit(slot_data["item"])

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_EXIT:
		if is_hovered:
			is_hovered = false
			slot_unhovered.emit()
