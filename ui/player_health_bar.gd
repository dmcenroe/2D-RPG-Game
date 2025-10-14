extends ProgressBar

func _ready() -> void:
		UIEvents.player_health_changed.connect(_on_health_changed)

func _on_health_changed(current: int, maximum: int) -> void:
	max_value = maximum
	value = current
