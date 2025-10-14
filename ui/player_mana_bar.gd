extends ProgressBar

@onready var mana_label = $ManaLabel

func _ready() -> void:
		UIEvents.player_mana_changed.connect(_on_mana_changed)

func _on_mana_changed(current: int, maximum: int) -> void:
	max_value = maximum
	value = current
	mana_label.text = str(int(value))
