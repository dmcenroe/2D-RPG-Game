extends CharacterBody2D

# === CHARACTER INFO ===
@export_group("Character Info")
@export var character_name: String = "Adventurer"
@export_enum("Warrior", "Wizard", "Druid", "Shaman", "Ranger", "Rogue") var character_class: String = "Warrior"
@export_enum("Human", "Elf", "Dwarf", "Halfling", "Gnome", "Barbarian") var character_race: String = "Human"
@export var character_level: int = 1

# Resources
@export var base_health: int = 20
@export var base_mana: int = 50

var current_health: int
var current_mana: int

# Movement
@export var speed: float = 200

# Damage
@export var base_damage: int = 2

# Regen rates (per second)
@export var health_regen: int = 1
@export var mana_regen: int = 1
@export var ooc_health_regen: int = 2
@export var ooc_mana_regen: int = 2

# Base stats
@export var strength: int = 10
@export var intelligence: int = 10
@export var agility: int = 10
@export var dexterity: int = 10
@export var wisdom: int = 10
@export var stamina: int = 10
@export var charisma: int = 10

# Stat Scaling
@export var health_per_stamina: int = 10
@export var mana_per_wis: int = 10
@export var spell_damage_per_int: float = 0.0020 # 5 int = 1% spell dmg
@export var spell_crit_per_int: float = 0.0005 # 20 int = 1% spell crit
@export var dmg_per_str: float = 0.0020 # 5 str = 1% melee dmg
@export var melee_crit_per_str: float = 0.0005 # 20 str = 1% melee crit
@export var accuracy_per_dex: float = 0.0010 # 10 dex = 1% accuracy bonus
@export var proc_per_dex: float = 0.0005 # 20 dex = 1% proc bonus
@export var dodge_per_agi: float = 0.0010 # 10 agi = 1% dodge bonus
@export var speed_per_agi: float = 0.0020 # 5 agi = 1% speed boost

@onready var combat_controller = $PlayerCombatController
@onready var ability_controller = $AbilityController
@onready var experience_manager = $ExperienceManager

var bonus_spell_dmg: float = 0.0
var bonus_spell_crit: float = 0.0
var bonus_melee_dmg: float = 0.0
var bonus_melee_crit: float = 0.0
var bonus_melee_accuracy: float = 0.0
var bonus_proc_rate: float = 0.0
var bonus_dodge: float = 0.0

var current_target: Node

func _ready() -> void:
	combat_controller.initialize(base_damage)
	call_deferred("_initialize_stats")
	
	
	# Subscribe to global tick
	GameTick.tick.connect(_on_tick)

func _initialize_stats() -> void:
	calculate_stats()
	current_health = base_health
	current_mana = base_mana
	UIEvents.player_health_changed.emit(current_health, base_health)
	UIEvents.player_mana_changed.emit(current_mana, base_mana)
	
func _physics_process(delta: float) -> void:
	Movement.apply_input(self, speed, delta)
	
func _on_tick() -> void:
	# Apply regen
	if current_health < base_health:
		modify_health(health_regen)
	
	if current_mana < base_mana:
		modify_mana(mana_regen)
	
# Health
func modify_health(amount: int) -> void:
	current_health = clamp(current_health + amount, 0, base_health)
	UIEvents.player_health_changed.emit(current_health, base_health)

func take_damage(amount: int, attacker:Node = null) -> void:
	combat_controller.take_damage(amount, attacker)
	
# Mana
func modify_mana(amount: int) -> void:
	current_mana = clamp(current_mana + amount, 0, base_mana)
	UIEvents.player_mana_changed.emit(current_mana, base_mana)

func has_mana(amount: int) -> bool:
	return current_mana >= amount

func spend_mana(amount: int) -> bool:
	if has_mana(amount):
		modify_mana(-amount)
		return true
	return false
	
# Stats
func get_stat(stat_name: String) -> int:
	match stat_name.to_lower():
		"strength":
			return strength
		"intelligence":
			return intelligence
		"agility":
			return agility
		_:
			return 0

func calculate_stats() -> void:
	base_health = health_per_stamina * stamina
	base_mana = mana_per_wis * wisdom
	speed = speed * (1 + agility * speed_per_agi) # 5 AGI = 1% Speed
	bonus_spell_dmg = intelligence * 0.0020      # 5 INT = 1% Spell Damage
	bonus_spell_crit = intelligence * 0.0005      # 20 INT = 1% Spell Crit
	bonus_melee_dmg = strength * 0.0020          # 5 STR = 1% Melee Damage
	bonus_melee_crit = strength * 0.0005          # 20 STR = 1% Melee Crit
	bonus_melee_accuracy = dexterity * 0.0010         # 10 DEX = 1% Accuracy
	bonus_proc_rate = dexterity * 0.0005         # 20 DEX = 1% Proc Chance
	bonus_dodge = agility * 0.0010           # 10 AGI = 1% Dodge
