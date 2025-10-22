# inventory_test.gd
extends Node

@onready var inventory = $Inventory

# Load your item resources
@export var rusty_dagger: Item
@export var orc_ear: Item
@export var mysterious_amulet: Item

func _ready() -> void:
	# Connect to inventory signals to see what's happening
	inventory.item_added.connect(_on_item_added)
	
	# Wait a frame for everything to initialize
	await get_tree().process_frame
	
	# Test adding items
	print("\n=== Testing Inventory ===")
	inventory.add_item(rusty_dagger, 1)
	inventory.add_item(orc_ear, 2)
	inventory.add_item(mysterious_amulet, 1)
	
	# Try adding a duplicate unique item (should fail)
	print("\n--- Trying to add duplicate unique item ---")
	inventory.add_item(mysterious_amulet, 1)
	
	# Print inventory contents
	print("\n--- Current Inventory ---")
	for i in range(inventory.items.size()):
		var slot = inventory.items[i]
		if slot != null:
			print("Slot %d: %s x%d" % [i, slot["item"].item_name, slot["quantity"]])

func _on_item_added(item: Item, quantity: int):
	print("Added: %s x%d" % [item.item_name, quantity])
