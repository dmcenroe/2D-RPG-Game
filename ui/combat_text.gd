extends Label

@export var float_distance: float = 40.0
@export var fade_duration: float = 1.5

var initial_position: Vector2

func _ready() -> void:
	initial_position = position  # Store the starting position
	hide()

func show_damage(amount: int) -> void:
	text = str(amount)
	modulate.a = 1.0
	position = initial_position  # Reset to starting position
	show()
	animate_text()

func animate_text() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_property(self, "position:y", initial_position.y - float_distance, fade_duration)
	tween.chain()
	tween.tween_callback(hide)
