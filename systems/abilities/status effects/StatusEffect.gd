# StatusEffect.gd
extends Node
class_name StatusEffect

var duration: float = 0
var effect_type: String = ""
var caster: Node

var time_remaining: float

func _ready() -> void:
	time_remaining = duration

	# Subscribe to tick for duration tracking
	GameTick.tick.connect(_on_tick_duration)

func _on_tick_duration() -> void:
	time_remaining -= GameTick.tick_interval
	
	if time_remaining <= 0:
		remove()

func refresh(new_duration: float) -> void:
	duration = new_duration
	time_remaining = duration

func remove() -> void:
	if GameTick.tick.is_connected(_on_tick_duration):
		GameTick.tick.disconnect(_on_tick_duration)
	queue_free()

# Static helper method to apply status effects with stacking prevention
static func apply_to_target(status_effect: StatusEffect, target: Node) -> void:
	var effect_class = status_effect.get_script()
	
	# Check if target already has this status effect type
	for child in target.get_children():
		if child is StatusEffect and child.get_script() == effect_class:
			# Found existing effect - refresh it instead of stacking
			child.refresh(status_effect.duration)
			# Clean up the new effect since we're not using it
			status_effect.queue_free()
			return
	
	# No existing effect found - add the new one
	target.add_child(status_effect)
