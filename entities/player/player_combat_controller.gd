extends "res://systems/combat/BaseCombatController.gd"

@export var attack_rate := 5.0 # seconds between attacks

@onready var attack_timer = $AttackTimer
@onready var player = get_parent()
@onready var combat_text: Label = $CombatText
@onready var animation_controller = get_parent().get_node("PlayerAnimationController")
@onready var chat_box = get_tree().get_first_node_in_group("chat_box") 

var last_printed_second: int = -1 # this is just to check that auto attacks are working
var auto_attack_enabled := false

#var base_health: int
#var current_health: int
var base_damage : int
#var base_mana: int
#var current_mana: int

func _ready() -> void:
	attack_timer.start(0.0) # first attack happens with no delay
	attack_timer.wait_time = attack_rate

func initialize(damage: int) -> void:
	#base_health = health
	#base_mana = mana
	base_damage = damage
	#current_health = health
	#current_mana = mana
	#call_deferred("_emit_initial_health_mana")
	
#func _emit_initial_health_mana() -> void:
	#UIEvents.player_health_changed.emit(current_health, base_health)
	#UIEvents.player_mana_changed.emit(current_mana, base_mana)

func _process(delta: float) -> void:
	if auto_attack_enabled:
		attempt_attack()

func toggle_auto_attack() -> void:
	if !auto_attack_enabled:
		auto_attack_enabled = true
		chat_box.add_message("Auto attack on")
	elif auto_attack_enabled:
		auto_attack_enabled = false
		chat_box.add_message("[color=red]Auto attack off[/color]")

func attempt_attack() -> void:
		if not attack_timer.is_stopped():
			return
	
		if not player.current_target:
			chat_box.add_message("[color=red]You don't have a target![/color]")
			return
			
		if !target_in_range():
			chat_box.add_message("[color=red]Target is out of range![/color]")
			return
		
		if attack_timer.is_stopped() and target_in_range() and player.current_target:
			perform_attack(base_damage, player)
			animation_controller.play_attack()
			attack_timer.start()

func take_damage(amount: int, attacker: Node) -> void:
	#complex combat code goes here (prob a helper func or generic combat controller code?)
	_update_combat_text(amount)
	player.modify_health(-amount)
	
	if player.current_health <= 0:
		die()

func die() -> void:
	pass
	# Handle death

func _update_combat_text(amount: int) -> void:
	combat_text.show_damage(amount)

func on_target_death():
	toggle_auto_attack()
	clear_target()

#cast_spell(spell_id)
#
#use_ability(ability_id, target)
