# movement.gd

class_name Movement

static func apply_input(body: CharacterBody2D, speed: float, delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	body.velocity = input_dir * speed
	body.move_and_slide()
