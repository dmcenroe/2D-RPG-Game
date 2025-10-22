extends Area2D

@onready var entity = get_parent()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	# Check if THIS enemy uses proximity aggro
	if entity.is_in_group("enemies") and not entity.has_proximity_aggro():
		return
		
	if body.is_in_group("enemies"):
		entity.add_nearby_enemy(body)
		
		# If the nearby enemy is already aggro'd, this one joins the fight
		if body.is_aggro:
			entity.enemy_aggro(body.current_target)
		
	if body.is_in_group("player"):
		entity.enemy_aggro(body)
		# Alert all nearby enemies
		for enemy in entity.nearby_enemies:
			enemy.enemy_aggro(body)

func _on_body_exited(body: Node2D) -> void:
	# Check if THIS enemy uses proximity aggro
	if entity.is_in_group("enemies") and not entity.has_proximity_aggro():
		return
		
	if body.is_in_group("enemies"):
		entity.remove_nearby_enemy(body)
