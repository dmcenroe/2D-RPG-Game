extends GPUParticles2D

func _ready() -> void:
	emitting = true
	await get_tree().create_timer(lifetime + 5).timeout
	queue_free()

func setup(cast_time: float) -> void:
	lifetime = cast_time + .5
