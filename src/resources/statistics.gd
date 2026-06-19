extends Resource
class_name Statistics

@export var health: float
@export var health_regeneration: float

@export var mana: float
@export var mana_regeneration: float

@export var attack_damage: float
@export var ability_power: float
@export var adaptive_force: float

@export var armor: float
@export var magic_resistance: float

@export var attack_speed: float
@export var attack_speed_multiplier: float

@export var skill_haste: float
@export var ultimate_haste: float
@export var item_haste: float

@export var critical_chance: float
@export var critical_damage_multiplier: float

@export var move_speed: float
@export var move_speed_multiplier: float

@export var armor_penetration_flat: float
@export var armor_penetration_multiplier: float

@export var magic_penetration_flat: float
@export var magic_penetration_multiplier: float

@export var lifesteal: float
@export var omnivamp: float

@export var attack_range: float

@export var tenacity: float

@export var heal_shield_power_multiplier: float

@export var radius: float


func add(other: Statistics) -> void:
	health += other.health
	health_regeneration += other.health_regeneration

	mana += other.mana
	mana_regeneration += other.mana_regeneration

	attack_damage += other.attack_damage
	ability_power += other.ability_power
	adaptive_force += other.adaptive_force

	armor += other.armor
	magic_resistance += other.magic_resistance

	attack_speed += other.attack_speed
	attack_speed_multiplier += other.attack_speed_multiplier
	
	skill_haste += other.skill_haste
	ultimate_haste += other.ultimate_haste
	item_haste += other.item_haste

	critical_chance += other.critical_chance
	critical_damage_multiplier += other.critical_damage_multiplier

	move_speed += other.move_speed
	move_speed_multiplier += other.move_speed_multiplier

	armor_penetration_flat += other.armor_penetration_flat
	armor_penetration_multiplier += other.armor_penetration_multiplier

	magic_penetration_flat += other.magic_penetration_flat
	magic_penetration_multiplier += other.magic_penetration_multiplier

	lifesteal += other.lifesteal
	omnivamp += other.omnivamp

	attack_range += other.attack_range

	tenacity += other.tenacity

	heal_shield_power_multiplier += other.heal_shield_power_multiplier

	radius += other.radius


func multiply(value: float) -> void:
	health *= value
	health_regeneration *= value

	mana *= value
	mana_regeneration *= value

	attack_damage *= value
	ability_power *= value
	adaptive_force *= value

	armor *= value
	magic_resistance *= value

	attack_speed *= value
	attack_speed_multiplier *= value
	
	skill_haste *= value
	ultimate_haste *= value
	item_haste *= value

	critical_chance *= value
	critical_damage_multiplier *= value

	move_speed *= value
	move_speed_multiplier *= value

	armor_penetration_flat *= value
	armor_penetration_multiplier *= value

	magic_penetration_flat *= value
	magic_penetration_multiplier *= value

	lifesteal *= value
	omnivamp *= value

	attack_range *= value

	tenacity *= value

	heal_shield_power_multiplier *= value
	
	radius *= value
