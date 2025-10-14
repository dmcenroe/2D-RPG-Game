extends AbilityEffect
class_name RootEffect


func apply(source: Node, target: Node, ability: Ability = null) -> void:
	
	var root_status = RootStatusEffect.new()
	root_status.duration = ability.duration
	
	# Use the static helper method instead of add_child directly
	StatusEffect.apply_to_target(root_status, target)
