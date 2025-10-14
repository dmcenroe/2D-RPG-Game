# SnareStatusEffect.gd
extends StatusEffect
class_name DoTStatusEffect

var damage_per_tick
var tick_accumulator: float = 0.0
@export var tick_interval: float = 6.0

func _ready() -> void:
	super._ready()
	
	# Subscribe to global tick
	GameTick.tick.connect(_on_tick)
	
func _on_tick() -> void:
	apply_tick_damage()

func apply_tick_damage() -> void:
	var target = get_parent()
	if target and target.has_method("take_damage"):
		target.take_damage(damage_per_tick, null)

func remove() -> void:
	super.remove()
