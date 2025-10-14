extends Node2D

@onready var inventory = $Player/Inventory

@export var rusty_sword: Item
@export var leather_tunic: Item
@export var mysterious_amulet: Item

func _ready() -> void:
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	# Add test items
	if rusty_sword:
		inventory.add_item(rusty_sword, 1)
	if leather_tunic:
		inventory.add_item(leather_tunic, 1)
	if mysterious_amulet:
		inventory.add_item(mysterious_amulet, 1)
