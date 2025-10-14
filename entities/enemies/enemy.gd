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

func _ready():
	# NEW: Apply enemy data if it exists
	if enemy_data:
		apply_enemy_data()
	
	combat_controller.health_depleted.connect(_on_health_depleted)
	enemy_ready()  # Hook for child classes

func apply_enemy_data() -> void:
	# Apply stats to combat controller
	if combat_controller:
		combat_controller.max_health = enemy_data.max_health
		combat_controller.current_health = enemy_data.max_health
		combat_controller.base_damage = enemy_data.damage
	
	# Apply movement speed - REMOVE the has() check
	if movement_controller:
		movement_controller.base_move_speed = enemy_data.move_speed
	
	# Apply sprite
	if animated_sprite and enemy_data.sprite_frames:
		animated_sprite.sprite_frames = enemy_data.sprite_frames
		animated_sprite.play(enemy_data.default_animation)
	
	# Setup loot
	setup_loot()

func setup_loot() -> void:
	if not inventory or not enemy_data:
		return
	
	# Add items based on loot table (we'll implement this properly later)
	for loot_drop in enemy_data.loot_table:
		# TODO: Add loot logic here when we create LootDrop resource
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
	
	drop_loot()
	
	# Hook for enemy-specific death behavior
	on_death()
	died.emit()
	queue_free()

func drop_loot() -> void:
	# Transfer inventory to player
	var player = get_tree().get_first_node_in_group("player")
	if player and inventory:
		var player_inventory = player.get_node_or_null("Inventory")
		if player_inventory:
			for slot in inventory.items:
				if slot != null and slot["item"] != null:
					player_inventory.add_item(slot["item"], slot["quantity"])
					print("Dropped: ", slot["item"].item_name)

func on_death():
	pass  # Override in child classes for unique behavior
