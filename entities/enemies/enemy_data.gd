# enemy_data.gd
extends Resource
class_name EnemyData

@export var enemy_name: String = "Enemy"
@export var max_health: float = 10
@export var damage: float = 1
@export var sprite_frames: SpriteFrames  # The AnimatedSprite animation set
@export var default_animation: String = "idle"
@export var has_proximity_aggro: bool = true
@export var loot_table: Array[LootDrop] = []  # We can define this later

# Add any other stats you need
@export var move_speed: float = 200
@export var experience_reward: int = 10
