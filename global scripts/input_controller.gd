extends Node

@onready var combat_controller = get_parent().get_node("PlayerCombatController")
@onready var ability_controller = get_parent().get_node("AbilityController")

func _unhandled_input(event: InputEvent) -> void:
	# Combat actions
	if event.is_action_pressed("auto_attack"):
		if combat_controller:
			combat_controller.toggle_auto_attack()
	
	# Spell hotkeys
	if event.is_action_pressed("ability_1"):
		if ability_controller:
			ability_controller.cast_ability(0)
	
	if event.is_action_pressed("ability_2"):
		if ability_controller:
			ability_controller.cast_ability(1)
			
	if event.is_action_pressed("ability_3"):
		if ability_controller:
			ability_controller.cast_ability(2)
