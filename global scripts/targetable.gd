extends Node

@onready var player_combat_controller = get_tree().get_first_node_in_group("player").get_node("PlayerCombatController")

func _ready() -> void:
	var parent = get_parent()
	if parent is CharacterBody2D or parent is Area2D:
		parent.input_pickable = true
		parent.input_event.connect(_on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if player_combat_controller:
				player_combat_controller.set_target(get_parent())
