extends Label

func _ready() -> void:
	UIEvents.target_changed.connect(_on_target_changed)

func _on_target_changed(target: Node) -> void:
	if target:
		text = target.display_name
		visible = true
	else:
		text = ""
		visible = false
