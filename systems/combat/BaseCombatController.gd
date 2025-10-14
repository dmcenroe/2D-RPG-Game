# BaseCombatController.gd
extends Node

@export var base_melee_range := 90.0
@onready var entity = get_parent()

var target_in_melee_range:= false
signal ability_received(ability: Ability, caster: Node)

func set_target(target: Node) -> void:
	disconnect_died_signal()
	entity.current_target = target
	UIEvents.target_changed.emit(target)
	
	# Connect to new target
	if target != null and target.has_signal("died"):
		target.died.connect(_on_target_died)

func clear_target() -> void:
	disconnect_died_signal()
	entity.current_target = null
	UIEvents.target_changed.emit(entity.current_target)

func perform_attack(damage: int, attacker: Node) -> void:
	if entity.current_target.is_inside_tree() and entity.current_target.has_method("take_damage"):
		entity.current_target.take_damage(damage, attacker)
	
func disconnect_died_signal() -> void:
	if entity.current_target != null and is_instance_valid(entity.current_target):
		if entity.current_target.has_signal("died") and entity.current_target.died.is_connected(_on_target_died):
			entity.current_target.died.disconnect(_on_target_died)

func _on_target_died() -> void:
	#hook to player or enemy combat controller so they can do specific things when a target dies
	on_target_death()

func on_target_death():
	#virtual function - override in child class
	pass
	
func target_in_range(range: float = base_melee_range) -> bool:
	if not entity.current_target:
		return false
	
	
	if not entity:
		return false
	
	var distance = entity.global_position.distance_to(entity.current_target.global_position)
	return distance < range
