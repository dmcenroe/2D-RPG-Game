extends Area2D

#@onready var combat_controller = get_parent().get_node("PlayerCombatController")
#
#func _ready() -> void:
	#area_entered.connect(_on_area_entered)
	#area_exited.connect(_on_area_exited)
#
#func _on_area_entered(area: Node2D) -> void:
	#print("area entered")
	#
	#var enemy = area.get_parent()
	#
	#if enemy.is_in_group("enemies"):
		#combat_controller.in_melee_range(true, enemy)
#
#func _on_area_exited(area: Node2D) -> void:
	#print("body exited")
	#
	#var enemy = area.get_parent()
	#if enemy == combat_controller.current_target:
		#combat_controller.in_melee_range(false, enemy)
