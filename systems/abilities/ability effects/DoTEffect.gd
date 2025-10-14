extends AbilityEffect
class_name DoTEffect


func apply(source: Node, target: Node, ability: Ability = null) -> void:
	
	var dot_status = DoTStatusEffect.new()
	dot_status.duration = ability.duration
	dot_status.damage_per_tick = ability.base_damage
	#dot_status.source = source
	
	# Use the static helper method instead of add_child directly
	StatusEffect.apply_to_target(dot_status, target)
