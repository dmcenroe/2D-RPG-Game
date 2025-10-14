extends ProgressBar

@onready var player_ability_controller = get_tree().get_first_node_in_group("player").get_node("AbilityController")
@onready var cast_bar_label = $CastBarLabel

var is_casting: bool = false
var cast_time_remaining: float = 0.0
var cast_time_total: float = 0.0
	
func _ready() -> void:
	player_ability_controller.ability_cast.connect(_on_ability_cast)
	visible = false

func _process(delta: float) -> void:
	if is_casting:
		cast_time_remaining -= delta
		value = cast_time_remaining
		
		if cast_time_remaining <= 0:
			is_casting = false
			visible = false

func _on_ability_cast(ability_index:int) -> void:
	var ability_used = player_ability_controller.abilities[ability_index]
	
	# Start casting
	cast_time_total = ability_used.cast_time
	cast_time_remaining = cast_time_total
	max_value = cast_time_total
	value = cast_time_remaining
	is_casting = true
	visible = true
	
	# Update label
	if cast_bar_label:
		cast_bar_label.text = ability_used.ability_name
