# AbilityController.gd
extends Node

signal ability_cast(ability_index: int)

@export var abilities: Array[Resource] = []  # Array of ability resources
@onready var combat_controller = get_parent().get_node("PlayerCombatController")
@onready var entity = get_parent()
@onready var chat_box = get_tree().get_first_node_in_group("chat_box")

# Cooldown tracking
var ability_cooldowns: Array[float] = []

func _ready() -> void:
	# Initialize cooldown array
	ability_cooldowns.resize(abilities.size())
	for i in range(abilities.size()):
		ability_cooldowns[i] = 0.0

func _process(delta: float) -> void:
	# Tick down cooldowns
	for i in range(ability_cooldowns.size()):
		if ability_cooldowns[i] > 0:
			ability_cooldowns[i] -= delta

func cast_ability(index: int) -> void:
	if index >= abilities.size() or index < 0:
		return
	
	# Check if ability exists
	if not abilities[index]:
		if chat_box:
			chat_box.add_message("No ability in slot " + str(index + 1))
		return
	
	# Check cooldown
	if ability_cooldowns[index] > 0:
		if chat_box:
			chat_box.add_message("Ability on cooldown: " + str(ceil(ability_cooldowns[index])) + "s")
		return
	
	# Check if we have a target (for targeted abilities)
	if abilities[index].requires_target and not entity.current_target:
		if chat_box:
			chat_box.add_message("No target selected")
		return
	
	# Check range
	if abilities[index].requires_target:
		var distance = entity.global_position.distance_to(entity.current_target.global_position)
		if distance > abilities[index].cast_range:
			if chat_box:
				chat_box.add_message("Target out of range")
			return
	
	if not entity.current_mana > abilities[index].mana_cost:
		if chat_box:
				chat_box.add_message("Not enough mana")
		return
	
	# Cast the ability!
	perform_ability(index)
	ability_cooldowns[index] = abilities[index].cooldown
	ability_cast.emit(index)

func perform_ability(index: int) -> void:
	var ability = abilities[index]
	var target = entity.current_target
	
	if chat_box:
		chat_box.add_message("Cast: " + ability.ability_name)
		
	# Play casting animation on player
	#var animation_controller = entity.get_node_or_null("AnimationController")
	#if animation_controller and ability.cast_animation:
		#animation_controller.play_ability_cast(ability.cast_animation)
		
	if ability.cast_effect:
		var cast_point = entity.get_node_or_null("AnimatedSprite2D/CastPoint")
		if cast_point:
			var effect = ability.cast_effect.instantiate()
			effect.setup(ability.cast_time)
			cast_point.add_child(effect)
			# Effect should auto-delete when done (use GPUParticles2D with one-shot)
		
	# Wait for cast time if ability has one
	if ability.cast_time > 0:
		await get_tree().create_timer(ability.cast_time).timeout
	
	# Apply effects immediately (or wait for projectile to hit)
	
	#get the target of the ability
	var target_combat = target.get_node_or_null("EnemyCombatController")
	#select which spell effect area to show the particles (right now im hardcoding the feet but could use something stored in the ability to say which node it should go to
	var target_spell_effect_point = target.get_node_or_null("AnimatedSprite2D/SpellEffectFeet")
	#creating the spell effect, need a "target effect" on the ability to have a different spell effect for casting vs landing on the mob
	var target_effect = ability.cast_effect.instantiate()
	#how long the animation will play, again need to have a "target effect" ability landed duration differentiated from cast time
	target_effect.setup(ability.cast_time)
	#add it to the target node
	target_spell_effect_point.add_child(target_effect)
	
	if target_combat:
		target_combat.ability_received.emit(ability, entity)
	
	# Notify target they're receiving an ability
	if target_combat:
		target_combat.ability_received.emit(ability, entity)
	
	# Apply all effects
	for effect in ability.effects:
		if effect:
			effect.apply(entity, entity.current_target, ability)
	
	# Take the mana cost away from the caster
	entity.modify_mana(-ability.mana_cost)
