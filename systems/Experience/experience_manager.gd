extends Control
class_name ExperienceManager

## Modular Experience & Leveling System
## Add this as a child node to your Player
## Emits signals for XP gain, level up, etc.

signal level_up(new_level: int, old_level: int)

@export var level_data: LevelProgressionData
@export var starting_level: int = 1

@onready var xp_bar = $"../../UI/CanvasLayer/XPBar"

var current_level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 1000
var total_experience: int = 0

# Zone experience modifier (1.0 = normal, 1.5 = 50% bonus, 0.5 = 50% penalty)
var zone_experience_modifier: float = 1.0

func _ready() -> void:
	if level_data == null:
		push_error("ExperienceManager: No LevelProgressionData assigned!")
		return
	
	current_level = starting_level
	_update_experience_requirement()
	_apply_level_stats(current_level)
	UIEvents.enemy_died.connect(_grant_experience)
	UIEvents.quest_completed.connect(_grant_experience)

## Call this when the player kills an enemy or completes a quest
func _grant_experience(enemy: Enemy = null) -> void:
	if not enemy:
		print('no enemy')
	
	# calculate enemey exp
	var base_xp = level_data.calculate_enemy_experience(enemy.get_level(), current_level)
	
	# Apply zone modifier
	var modified_amount = int(base_xp * zone_experience_modifier)
	
	current_experience += modified_amount
	total_experience += modified_amount
	UIEvents.chat_message.emit("You gained %d experience!" % modified_amount, Color.WHITE)
	
	_update_ui()
	_check_for_level_up()

## Set the current zone's experience modifier
func set_zone_modifier(modifier: float) -> void:
	zone_experience_modifier = max(0.0, modifier)  # Prevent negative XP

## Main level up logic
func _check_for_level_up() -> void:
	while current_experience >= experience_to_next_level:
		if current_level >= level_data.max_level:
			current_experience = experience_to_next_level
			return
		
		var old_level = current_level
		current_experience -= experience_to_next_level
		current_level += 1
		
		_update_experience_requirement()
		_apply_level_stats(current_level)
		
		level_up.emit(current_level, old_level)

## Update XP needed for next level
func _update_experience_requirement() -> void:
	if level_data == null:
		return
	
	experience_to_next_level = level_data.get_experience_for_level(current_level + 1)

## Apply stat bonuses for the given level
func _apply_level_stats(level: int) -> void:
	if level_data == null:
		return

## Progress to next level (0.0 to 1.0)
func get_level_progress() -> float:
	if experience_to_next_level <= 0:
		return 1.0
	return float(current_experience) / float(experience_to_next_level)

## Progress as percentage (0 to 100)
func get_level_progress_percent() -> int:
	return int(get_level_progress() * 100)

## Check if at max level
func is_max_level() -> bool:
	return current_level >= level_data.max_level

## Save/Load support
func get_save_data() -> Dictionary:
	return {
		"current_level": current_level,
		"current_experience": current_experience,
		"total_experience": total_experience
	}

func load_save_data(data: Dictionary) -> void:
	current_level = data.get("current_level", 1)
	current_experience = data.get("current_experience", 0)
	total_experience = data.get("total_experience", 0)
	
	_update_experience_requirement()
	_apply_level_stats(current_level)

func _update_ui():
	xp_bar.value = get_level_progress_percent()
	xp_bar.max_value = 100
