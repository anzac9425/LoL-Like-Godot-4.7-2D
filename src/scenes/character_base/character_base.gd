extends Area2D
class_name CharacterBase


var character_data: CharacterData

var base_statistics: Statistics
var bonus_statistics: Statistics = Statistics.new()
var total_statistics: Statistics = Statistics.new()

var level: int
var experience: float

var current_health: float
var current_mana: float

# var buffs: Array[Buff] = []
# var items: Array[Item] = []
# var runes: Array[Rune] = []

var is_moving: bool
var target_position: Vector2


func _ready() -> void:
	base_statistics = character_data.statistics
	
	target_position = global_position
	
	calculate_statistics()
	
	current_health = total_statistics.health
	current_mana = total_statistics.mana
	
	add_child(character_data.character_logic.new())
	
	
func _physics_process(delta: float) -> void:
	if is_moving:
		global_position = global_position.move_toward(target_position, total_statistics.move_speed * delta)
		
		if global_position == target_position:
			is_moving = false


func move_to(pos: Vector2) -> void:
	target_position = pos
	is_moving = true


func calculate_statistics() -> void:
	total_statistics.health = base_statistics.health + bonus_statistics.health
	
	total_statistics.health_regeneration = base_statistics.health_regeneration + bonus_statistics.health_regeneration
	
	total_statistics.mana = base_statistics.mana + bonus_statistics.mana
	
	total_statistics.mana_regeneration = base_statistics.mana_regeneration + bonus_statistics.mana_regeneration
	
	total_statistics.attack_damage = base_statistics.attack_damage + bonus_statistics.attack_damage
	
	total_statistics.ability_power = base_statistics.ability_power + bonus_statistics.ability_power
	
	total_statistics.adaptive_force = base_statistics.adaptive_force + bonus_statistics.adaptive_force
	
	total_statistics.armor = base_statistics.armor + bonus_statistics.armor
	
	total_statistics.magic_resistance = base_statistics.magic_resistance + bonus_statistics.magic_resistance
	
	total_statistics.attack_speed = base_statistics.attack_speed + bonus_statistics.attack_speed
	
	total_statistics.attack_speed_multiplier = base_statistics.attack_speed_multiplier + bonus_statistics.attack_speed_multiplier
	
	total_statistics.skill_haste = base_statistics.skill_haste + bonus_statistics.skill_haste
	
	total_statistics.critical_chance = base_statistics.critical_chance + bonus_statistics.critical_chance
	
	total_statistics.critical_damage_multiplier = base_statistics.critical_damage_multiplier + bonus_statistics.critical_damage_multiplier
	
	total_statistics.move_speed = base_statistics.move_speed + bonus_statistics.move_speed
	
	total_statistics.armor_penetration_flat = base_statistics.armor_penetration_flat + bonus_statistics.armor_penetration_flat
	
	total_statistics.armor_penetration_multiplier = base_statistics.armor_penetration_multiplier + bonus_statistics.armor_penetration_multiplier
	
	total_statistics.magic_penetration_flat = base_statistics.magic_penetration_flat + bonus_statistics.magic_penetration_flat
	
	total_statistics.magic_penetration_multiplier = base_statistics.magic_penetration_multiplier + bonus_statistics.magic_penetration_multiplier
	
	total_statistics.lifesteal = base_statistics.lifesteal + bonus_statistics.lifesteal
	
	total_statistics.omnivamp = base_statistics.omnivamp + bonus_statistics.omnivamp
	
	total_statistics.attack_range = base_statistics.attack_range + bonus_statistics.attack_range
	
	total_statistics.tenacity = base_statistics.tenacity + bonus_statistics.tenacity
	
	total_statistics.heal_shield_power_multiplier = base_statistics.heal_shield_power_multiplier + bonus_statistics.heal_shield_power_multiplier
	
	
	if bonus_statistics.attack_damage >= bonus_statistics.ability_power:
		total_statistics.attack_damage += total_statistics.adaptive_force
		
	else:
		total_statistics.ability_power += total_statistics.adaptive_force
	
	total_statistics.attack_speed *= 1.0 + total_statistics.attack_speed_multiplier
	
