# Ability.gd
extends Resource
class_name Ability

# === BASIC INFO ===
@export_category("Basic Info")
@export var ability_name: String = "New Ability"
@export var description: String = ""
@export var icon: Texture2D
@export var ability_level: int = 1
@export_flags("Warrior", "Wizard", "Druid", "Shaman") var ability_classes: int = 0

# === CASTING ===
@export_category("Casting Properties")
@export var cooldown: float = 1.5
@export var cast_range: float = 500.0
@export var cast_time: float = 1
@export var duration: float = 0
@export var mana_cost: int = 0
@export var max_effective_level: int = 100
@export var requires_target: bool = true

# === DAMAGE ===
@export_category("Damage")
@export_range(0, 1000) var base_damage: int = 100
@export_enum("Physical", "Magic", "Fire", "Cold", "Poison", "Disease") var resist_type: String = "Magic"

# === CROWD CONTROL ===
@export_category("Crowd Control")
@export_range(0.0, 1.0, 0.1) var snare_percent: float = 0
@export var root_break_chance: float = 0
@export var charm_break_chance: float = 0

# === BUFFS / DEBUFFS ===
@export_category("Stat buffs / debuffs")
@export var strength_adjustment: int = 0
@export var stamina_adjustment: int = 0
@export var agility_adjustment: int = 0
@export var int_adjustment: int = 0
@export var wis_adjustment: int = 0

@export_category("Melee buffs / debuffs")
@export var attack_adjustment: int = 0
@export var attack_speed_adjustment_percent: float = 0

@export_category("HP & Armor buffs / debuffs")
@export var HP_adjustment: int = 0
@export var HP_regen_adjustment: int = 0
@export var armor_adjustment: int = 0

@export_category("Mana buffs / debuffs")
@export var Mana_adjustment: int = 0
@export var Mana_regen_adjustment: int = 0

@export_category("Resist buffs / debuffs")
@export var MR_adjustment: int = 0
@export var FR_adjustment: int = 0
@export var CR_adjustment: int = 0
@export var DR_adjustment: int = 0
@export var PR_adjustment: int = 0

# === HEALING ===
@export_category("Healing")
@export var heal_amount: int = 0

# === VISUAL/AUDIO ===
@export_category("Effects")
@export var cast_animation: String
@export var impact_animation: String
@export var cast_effect: PackedScene


# === ADVANCED ===
@export_category("Advanced")
# Array of effects this ability applies
@export var effects: Array[AbilityEffect] = []
