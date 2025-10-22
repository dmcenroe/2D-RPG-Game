extends Node2D

@onready var exp_manager = $ExperienceManager
@onready var level_label = $UI/LevelLabel
@onready var xp_label = $UI/XPLabel
@onready var xp_bar = $UI/XPBar
@onready var kill_button = $UI/KillEnemyButton
@onready var quest_button = $UI/CompleteQuestButton
@onready var zone_button = $UI/ChangeZoneButton

var current_zone = "normal_zone"

func _ready():
	# Connect signals
	exp_manager.experience_gained.connect(_on_exp_gained)
	exp_manager.level_up.connect(_on_level_up)
	
	# Connect buttons
	kill_button.pressed.connect(_on_kill_enemy)
	quest_button.pressed.connect(_on_complete_quest)
	zone_button.pressed.connect(_on_change_zone)
	
	# Initial zone
	exp_manager.set_zone_modifier(1.0)
	_update_zone_button()
	
	# Initial UI update
	_update_ui()
	
	print("=== XP System Test Ready ===")
	print("Current Level: %d" % exp_manager.current_level)
	print("XP to Next Level: %d" % exp_manager.experience_to_next_level)
	print("\nControls:")
	print("- Click 'Kill Enemy' to gain XP from a same-level enemy")
	print("- Click 'Complete Quest' to gain 500 XP")
	print("- Click 'Change Zone' to cycle through zone XP modifiers")

func _on_kill_enemy():
	# Simulate killing a same-level enemy
	var xp = exp_manager.level_data.calculate_enemy_experience(
		exp_manager.current_level,  # Enemy level = player level
		exp_manager.current_level,
		100  # Base XP
	)
	exp_manager.grant_experience(xp, "Orc")

func _on_complete_quest():
	exp_manager.grant_experience(500, "Test Quest")

func _on_change_zone():
	# Cycle through zones
	match current_zone:
		"normal_zone":
			current_zone = "tutorial_zone"
			exp_manager.set_zone_modifier(1.5)
		"tutorial_zone":
			current_zone = "hard_zone"
			exp_manager.set_zone_modifier(0.8)
		"hard_zone":
			current_zone = "normal_zone"
			exp_manager.set_zone_modifier(1.0)
	
	_update_zone_button()
	print("Changed to %s (%.1fx XP)" % [current_zone, exp_manager.zone_experience_modifier])

func _on_exp_gained(amount: int, source: String):
	_update_ui()
	print("Gained %d XP from %s | Progress: %d%%" % [
		amount, 
		source, 
		exp_manager.get_level_progress_percent()
	])

func _on_level_up(new_level: int, old_level: int):
	print("\n=== LEVEL UP! %d -> %d ===" % [old_level, new_level])
	print("XP needed for next level: %d\n" % exp_manager.experience_to_next_level)
	_update_ui()

func _update_ui():
	level_label.text = "Level %d" % exp_manager.current_level
	xp_label.text = "%d / %d XP (%d%%)" % [
		exp_manager.current_experience,
		exp_manager.experience_to_next_level,
		exp_manager.get_level_progress_percent()
	]
	xp_bar.value = exp_manager.get_level_progress_percent()
	xp_bar.max_value = 100

func _update_zone_button():
	zone_button.text = "Zone: %s (%.1fx XP)" % [
		current_zone,
		exp_manager.zone_experience_modifier
	]
