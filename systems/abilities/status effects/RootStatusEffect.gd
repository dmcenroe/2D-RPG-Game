# RootStatusEffect.gd
extends StatusEffect
class_name RootStatusEffect

var chance_to_break: float
var original_speed: float
var movement_controller: Node

func _ready() -> void:
	super._ready()
	movement_controller = get_parent().get_node_or_null("EnemyMovementController")
	if movement_controller:
		original_speed = movement_controller.base_move_speed
		movement_controller.base_move_speed *= 0.0

func remove() -> void:
	if movement_controller:
		movement_controller.base_move_speed = original_speed
	super.remove()
