extends AbilityEffect
class_name DamageEffect

@export var damage: int = 0

func apply(source: Node, target: Node, ability: Ability = null) -> void:
	var target_combat = target.get_node_or_null("EnemyCombatController")
	if target_combat:
		target_combat.take_damage(damage)
