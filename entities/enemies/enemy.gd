# BaseEnemy.gd
extends CharacterBody2D
class_name Enemy

signal died

@export var enemy_data: EnemyData

@onready var combat_controller = $EnemyCombatController
@onready var movement_controller = $EnemyMovementController
@onready var animation_controller = $EnemyAnimationController
@onready var animated_sprite = $AnimatedSprite2D
@onready var inventory = $Inventory

var is_dead: bool = false
var is_aggro: bool = false
var current_target: Node
var nearby_enemies: Array[Node2D] = []

# === CACHED RUNTIME PROPERTIES ===
# These can be modified during gameplay (buffs, debuffs, transformations, etc.)
var display_name: String = "Unknown Enemy"

func _ready():
	if enemy_data:
		apply_enemy_data()
	
	combat_controller.health_depleted.connect(_on_health_depleted)
	enemy_ready()

func apply_enemy_data() -> void:
	# Cache properties that might change at runtime
	display_name = enemy_data.enemy_name
	
	# Apply stats to combat controller
	if combat_controller:
		combat_controller.max_health = enemy_data.max_health
		combat_controller.current_health = enemy_data.max_health
		combat_controller.base_damage = enemy_data.damage
	
	# Apply movement speed (can be modified by snares/buffs)
	if movement_controller:
		movement_controller.base_move_speed = enemy_data.move_speed
	
	# Apply sprite
	if animated_sprite and enemy_data.sprite_frames:
		animated_sprite.sprite_frames = enemy_data.sprite_frames
		animated_sprite.play(enemy_data.default_animation)
	
	setup_loot()

# === STATIC CONFIGURATION GETTERS ===
# These properties are defined in enemy_data and never change at runtime
# Access them via methods to maintain single source of truth

func has_proximity_aggro() -> bool:
	return enemy_data.has_proximity_aggro if enemy_data else true

func get_level() -> int:
	return enemy_data.level if enemy_data else 0

func get_sprite_frames() -> SpriteFrames:
	return enemy_data.sprite_frames

# Add more static getters as needed:
# func get_faction() -> String:
#     return enemy_data.faction if enemy_data else "neutral"

func setup_loot() -> void:
	# Loot is now handled by the loot_table in enemy_data
	# This function is kept for future pre-population of guaranteed loot if needed
	pass

func enemy_ready():
	pass  # Override in child classes

func enemy_aggro(target: Node) -> void:
	if is_aggro:
		return
	
	is_aggro = true
	current_target = target
	if not nearby_enemies.is_empty():
		for enemy in nearby_enemies:
			enemy.enemy_aggro(target)

func add_nearby_enemy(enemy: Node2D) -> void:
	if enemy not in nearby_enemies:
		nearby_enemies.append(enemy)

func remove_nearby_enemy(enemy: Node2D) -> void:
	nearby_enemies.erase(enemy)

func take_damage(amount: int, attacker: Node = null) -> void:
	combat_controller.take_damage(amount, attacker)

func _on_health_depleted():
	if is_dead:
		return
	die()

func die():
	is_dead = true
	set_physics_process(false)
	
	UIEvents.enemy_died.emit(self)
	drop_loot()
	
	on_death()
	died.emit()
	queue_free()

func drop_loot() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("ERROR: No player found in scene!")
		return
	
	var player_inventory = player.get_node_or_null("Inventory")
	if not player_inventory:
		print("ERROR: Player has no Inventory node!")
		return
	
	print("\n=== ", display_name, " died! Rolling loot... ===")
	
	# Roll on loot table from enemy_data
	if enemy_data and enemy_data.loot_table:
		var drops: Array[Dictionary] = []
		
		# Safely roll loot with error handling
		if enemy_data.loot_table.validate():
			drops = enemy_data.loot_table.roll_all()
		else:
			print("  WARNING: Loot table validation failed!")
		
		if drops.is_empty():
			print("  Nothing dropped from loot table!")
		else:
			for drop in drops:
				if drop.has("item") and drop["item"] != null:
					var quantity = drop.get("quantity", 1)
					if player_inventory.add_item(drop["item"], quantity):
						print("  ✓ Dropped: ", drop["item"].item_name, " x", quantity)
					else:
						print("  ✗ Failed to add: ", drop["item"].item_name, " (inventory full?)")
	else:
		print("  No loot table configured")
	
	# Also transfer any items in the enemy's inventory (hand-placed loot)
	if inventory and inventory.items:
		var found_manual_loot = false
		for slot in inventory.items:
			if slot != null and slot.has("item") and slot["item"] != null:
				if player_inventory.add_item(slot["item"], slot["quantity"]):
					print("  ✓ Dropped from inventory: ", slot["item"].item_name, " x", slot["quantity"])
					found_manual_loot = true
				else:
					print("  ✗ Failed to add from inventory: ", slot["item"].item_name)
		
		if not found_manual_loot and enemy_data and not enemy_data.loot_table:
			print("  Inventory empty")
	
	print("=================================\n")

func on_death():
	pass  # Override in child classes for unique behavior
