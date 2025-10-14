# TickManager.gd (Autoload as "GameTick")
extends Node

signal tick  # Emitted every tick_interval

@export var tick_interval: float = 6.0
@export var paused: bool = false

var tick_accumulator: float = 0.0
var tick_count: int = 0

func _process(delta):
	if paused:
		return
	
	tick_accumulator += delta
	
	while tick_accumulator >= tick_interval:
		tick_accumulator -= tick_interval
		tick_count += 1
		tick.emit()
		
		#if OS.is_debug_build():
			#print("[GameTick] Tick #", tick_count)

func pause_ticks() -> void:
	paused = true

func resume_ticks() -> void:
	paused = false

func get_time_until_next_tick() -> float:
	return tick_interval - tick_accumulator
