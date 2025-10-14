extends "res://systems/combat/BaseCombatController.gd"

@export var attack_rate := 4.0

@export var movement_controller: Node

@onready var attack_timer = $AttackTimer
@onready var combat_text = $CombatText
@onready var animation_controller = get_parent().get_node("EnemyAnimationController")

signal health_depleted
var max_health: int
var current_health: int
var base_damage : int


func _process(delta:float) -> void:
	if entity.is_aggro:
		attempt_attack()

func _ready() -> void:
	attack_timer.start(0.0)
	attack_timer.wait_time = attack_rate
	ability_received.connect(_on_ability_received)
	
func initialize(health: int, damage: int) -> void:
	max_health = health
	base_damage = damage
	current_health = health
	UIEvents.target_health_changed.emit(current_health, max_health)

func take_damage(amount: int, source:Node) -> void:
	combat_text.show_damage(amount)
	entity.enemy_aggro(source)
	
	current_health -= amount
	current_health = max(current_health, 0)  # Don't go below 0
	
	UIEvents.target_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()

func apply_effect(amount: float, source:Node) -> void:
	entity.enemy_aggro(source)
	movement_controller.move_speed = movement_controller.move_speed * amount

func _on_ability_received(ability: Ability, source: Node) -> void:
	print("Received ability: ", ability.ability_name, " from ", source.name)
	# React to being attacked
	entity.enemy_aggro(source)

func die() -> void:
	health_depleted.emit()
	
func attempt_attack() -> void:
	if not attack_timer.is_stopped():
		return
	
	if not entity.current_target:
		return
			
	if !target_in_range():
		return
		
	if attack_timer.is_stopped() and target_in_range() and entity.current_target:
		perform_attack(base_damage, entity)
		animation_controller.play_attack(entity.current_target)
		attack_timer.start()
