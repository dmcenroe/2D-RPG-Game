extends Node2D

@onready var animated_sprite = get_parent().get_node("AnimatedSprite2D")
@onready var enemy = get_parent()

var is_attacking := false

func _ready() -> void:
	#animated_sprite.sprite_frames.set_animation_loop("Idle", true)
	animated_sprite.sprite_frames = enemy.get_sprite_frames()
	animated_sprite.sprite_frames.set_animation_loop("attack01", false)  # Don't loop attack
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")

func _process(delta: float) -> void:
	if not is_attacking:
		update_animation()

func update_animation() -> void:
	
	if enemy.velocity.x < 0:
		animated_sprite.flip_h = true  # Face left
	elif enemy.velocity.x > 0:
		animated_sprite.flip_h = false  # Face right
		
	if enemy.velocity.length() > 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")
	
func play_attack(current_target:Node) -> void:
	if enemy.global_position.x < current_target.global_position.x:
		# Player is on left, face right
		animated_sprite.flip_h = false
	else:
		# Player is on right, face left
		animated_sprite.flip_h = true
	is_attacking = true
	animated_sprite.play("attack01")

func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack01":
		is_attacking = false
	
