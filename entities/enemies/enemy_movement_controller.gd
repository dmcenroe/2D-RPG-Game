extends Node

@export var entity: CharacterBody2D  # Reference to the enemy
@export var base_move_speed: float = 100.0
@export var attack_range: float = 90.0

func _ready() -> void:
	entity = get_parent()

func _physics_process(delta: float) -> void:
	#print(base_move_speed)
	if not entity.is_aggro or entity.current_target == null or entity == null:
		return
	
	var distance_to_player = entity.global_position.distance_to(entity.current_target.global_position)
	
	# Move towards player if outside attack range
	if distance_to_player > attack_range:
		var direction = (entity.current_target.global_position - entity.global_position).normalized()
		entity.velocity = direction * base_move_speed
		entity.move_and_slide()
	else:
		# Stop moving when in attack range
		entity.velocity = Vector2.ZERO
