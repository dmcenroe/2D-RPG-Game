extends ProgressBar

func _ready() -> void:
	UIEvents.target_changed.connect(_on_target_changed)
	UIEvents.target_health_changed.connect(_on_health_changed)
	
	# Hide bar initially
	visible = false

func _on_target_changed(target: Node) -> void:
	if target:
		var current_enemy_controller = target.get_node_or_null("EnemyCombatController")
		#
		if current_enemy_controller:
			## Update bar immediately
			max_value = current_enemy_controller.max_health
			value = current_enemy_controller.current_health
			visible = true
		else:
			visible = false
	else:
		visible = false

func _on_health_changed(current: int, maximum: int) -> void:
	max_value = maximum
	value = current
