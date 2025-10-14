# SpawnPoint.gd
extends Marker2D
class_name SpawnPoint

@export var enemy_type: String = "orc"  # Just the name
@export var spawn_on_ready: bool = true
@export var respawn_delay: float = 10.0

var enemy_scene: PackedScene
var enemy_data: EnemyData
var respawn_timer: float = 0.0
var is_respawning: bool = false

func _ready():
	# Load the ONE generic enemy scene
	enemy_scene = load("res://entities/enemies/enemy.tscn")
	if not enemy_scene:
		push_error("Generic enemy scene not found!")
		return
	
	# Load the specific enemy data resource
	var data_path = "res://entities/enemies/enemy_files/" + enemy_type + "_data.tres"
	if ResourceLoader.exists(data_path):
		enemy_data = load(data_path)
	else:
		push_error("Enemy data not found: " + data_path)
		return
	
	if spawn_on_ready:
		spawn_enemy.call_deferred()

func _process(delta):
	if is_respawning:
		respawn_timer -= delta
		if respawn_timer <= 0:
			is_respawning = false
			spawn_enemy()

func spawn_enemy() -> Enemy:
	if not enemy_scene or not enemy_data:
		return null
	
	var enemy = enemy_scene.instantiate()
	enemy.enemy_data = enemy_data  # Assign the data!
	enemy.global_position = global_position
	
	get_parent().add_child(enemy)
	return enemy

func _on_enemy_died():
	# Start respawn timer
	is_respawning = true
	respawn_timer = respawn_delay
