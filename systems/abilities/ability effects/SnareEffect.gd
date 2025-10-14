extends AbilityEffect
class_name SnareEffect


func apply(source: Node, target: Node, ability: Ability = null) -> void:
	
	var snare_status = SnareStatusEffect.new()
	snare_status.duration = ability.duration
	snare_status.snare_percent = ability.snare_percent
	
	# Use the static helper method instead of add_child directly
	StatusEffect.apply_to_target(snare_status, target)
