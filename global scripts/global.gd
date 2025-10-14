extends Node

@onready var player_combat_controller = get_tree().get_first_node_in_group("player").get_node("PlayerCombatController")

func _ready() -> void:
	await get_tree().process_frame
	
	var usable_rect = DisplayServer.screen_get_usable_rect()
	
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(usable_rect.size)
	DisplayServer.window_set_position(usable_rect.position)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if we clicked on nothing (empty space)
			var space_state = get_viewport().world_2d.direct_space_state
			var query = PhysicsPointQueryParameters2D.new()
			query.position = get_viewport().get_mouse_position()
			var result = space_state.intersect_point(query, 1)
			
			# If nothing was hit, clear target
			if result.is_empty():
				if player_combat_controller:
					player_combat_controller.clear_target()
