extends Resource
class_name LevelProgressionData

## Level progression rules - XP requirements and zone modifiers

@export var max_level: int = 60
@export var base_experience: int = 1000
@export var experience_curve: CurveType = CurveType.EXPONENTIAL
@export var xp_multiplier: float = 1.1
@export var zone_modifiers: Dictionary = {}

enum CurveType {
	LINEAR,
	EXPONENTIAL,
	POLYNOMIAL
}

## Get XP required to reach a specific level
func get_experience_for_level(level: int) -> int:
	if level <= 1:
		return 0
	
	if level > max_level:
		return 999999999
	
	match experience_curve:
		CurveType.LINEAR:
			return base_experience
		
		CurveType.EXPONENTIAL:
			return int(base_experience * pow(xp_multiplier, level - 2))
		
		CurveType.POLYNOMIAL:
			return int(base_experience + (pow(level - 1, 2) * 100))
	
	return base_experience

## Get zone XP modifier
func get_zone_modifier(zone_name: String) -> float:
	return zone_modifiers.get(zone_name, 1.0)

## Get total XP to reach a level from level 1
func get_total_experience_to_level(level: int) -> int:
	var total = 0
	for i in range(2, level + 1):
		total += get_experience_for_level(i)
	return total

## Calculate enemy XP based on level difference
func calculate_enemy_experience(enemy_level: int, player_level: int, base_xp: int = 100) -> int:
	if enemy_level <= 0:
		return 0
	
	var level_diff = enemy_level - player_level
	
	# Define multipliers for each level difference
	var xp_multipliers = {
		-4: 0.25,
		-3: 0.75,
		-2: 0.75,
		-1: 0.75,
		0: 1.0,
		1: 1.1,
		2: 1.2,
		3: 1.3
	}
	
	# Handle extremes
	if level_diff <= -5:
		return 0
	elif level_diff >= 3:
		# Cap at 1.3x for anything 3+ levels higher
		return int(base_xp * 1.3)
	
	# Use lookup table
	var multiplier = xp_multipliers.get(level_diff, 1.0)
	return int(base_xp * multiplier)
