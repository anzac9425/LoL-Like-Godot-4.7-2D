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
var barriers: Array[Barrier]

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
	
	queue_redraw()
	
	
func _physics_process(delta: float) -> void:
	if is_moving:
		global_position = global_position.move_toward(target_position, total_statistics.move_speed * delta)
		
		if global_position == target_position:
			is_moving = false
	
	if barriers:
		update_barriers(delta)
	

func _draw() -> void:
	var width: float = 256.0
	var height: float = 32.0
	
	var barrier_amount: float = 0.0
	
	for barrier in barriers:
		barrier_amount += barrier.amount
		
	var max_health_barrier: float = (total_statistics.health + barrier_amount)

	var health_ratio: float = current_health / max_health_barrier

	var barrier_ratio: float = barrier_amount / max_health_barrier

	var pos: Vector2 = Vector2(width / -2, -128.0)

	draw_rect(
		Rect2(pos, Vector2(width, height)),
		Color.BLACK
	)

	draw_rect(
		Rect2(pos, Vector2(width * health_ratio, height)),
		Color.RED
	)

	if barrier_amount:
		var barrier_x := pos.x + width * health_ratio
		var barrier_width: float = min(
			width * barrier_ratio,
			width - width * health_ratio
		)

		draw_rect(
			Rect2(
				Vector2(barrier_x, pos.y),
				Vector2(barrier_width, height)
			),
			Color.YELLOW
		)

	if total_statistics.health:
		for hp in range(100, int(max_health_barrier), 100):
			var x: float = pos.x + (float(hp) / max_health_barrier) * width

			draw_line(
				Vector2(x, pos.y + height * 0.5),
				Vector2(x, pos.y),
				Color.BLACK,
				1.0
			)

	if total_statistics.health > 1000:
		for hp in range(1000, int(max_health_barrier), 1000):
			var x := pos.x + (float(hp) / max_health_barrier) * width

			draw_line(
				Vector2(x, pos.y),
				Vector2(x, pos.y + height),
				Color.BLACK,
				2.0
			)

	draw_rect(
		Rect2(pos, Vector2(width, height)),
		Color.WHITE,
		false,
		2.0
	)
			
			
func update_barriers(delta: float) -> void:
	for i in range(barriers.size() - 1, -1, -1):
		var barrier: Barrier = barriers[i]

		barrier.remaining_duration -= delta

		if barrier.remaining_duration <= 0.0:
			barriers.remove_at(i)
			
			queue_redraw()


func move_to(pos: Vector2) -> void:
	target_position = pos
	is_moving = true
	
	var dmg: DamageInfo = DamageInfo.create(self, self)
	dmg.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.UNKNOWN, 10.0, true, true)
	Combat.apply_damage(dmg)
	Combat.apply_barrier(self, 128, 2.0)
	

func calculate_statistics() -> void:
	var old_total_statistics_health: float = total_statistics.health
	
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
	
	current_health += max(0.0, total_statistics.health - old_total_statistics_health)
