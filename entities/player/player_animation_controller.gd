extends Node2D

@onready var animated_sprite = get_parent().get_node("AnimatedSprite2D")
@onready var player = get_parent()

var is_attacking: bool = false
var is_casting: bool = false
var cast_point: Marker2D
var cast_point_offset_x: float
#@onready var player_combat_controller = get_parent().get_node("PlayerCombatController")

func _ready() -> void:
	#animated_sprite.sprite_frames.set_animation_loop("Idle", true)
	#animated_sprite.sprite_frames.set_animation_loop("Walk", true)
	cast_point = animated_sprite.get_node("CastPoint")
	cast_point_offset_x = abs(cast_point.position.x)
	animated_sprite.sprite_frames.set_animation_loop("Attack01", false)  # Don't loop attack
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("Idle")

func _process(delta: float) -> void:
	if not is_attacking or is_casting:
		update_animation()

func update_animation() -> void:
	
	if player.velocity.x < 0:
		animated_sprite.flip_h = true  # Face left
		cast_point.position.x = -cast_point_offset_x
		cast_point.scale.x = -1
	elif player.velocity.x > 0:
		animated_sprite.flip_h = false  # Face right
		cast_point.position.x = cast_point_offset_x
		cast_point.scale.x = 1
		
	if player.velocity.length() > 0:
		animated_sprite.play("Walk")
	else:
		animated_sprite.play("Idle")
	
func play_attack() -> void:
	animated_sprite.play("Attack01")
	is_attacking = true

func _on_animation_finished() -> void:
	if animated_sprite.animation == "Attack01":
		is_attacking = false
	elif is_casting:
		is_casting = false

func play_ability_cast(animation_name: String) -> void:
	is_casting = true
	animated_sprite.play(animation_name)
