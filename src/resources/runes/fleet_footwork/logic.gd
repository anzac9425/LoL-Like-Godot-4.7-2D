extends CharacterLogic


var charges: float = 0.0
var timer: Cooldown = Cooldown.new()

var last_position: Vector2
var traveled_distance: float


func _ready() -> void:
	last_position = character_base.global_position


func _physics_process(delta):
	if timer.remaining_duration > 0.0:
		timer.remaining_duration -= delta

		if timer.remaining_duration <= 0.0:
			character_base.calculate_statistics()
	
	var distance: float = character_base.global_position.distance_to(last_position)

	traveled_distance += distance

	last_position = character_base.global_position

	if traveled_distance >= 24.0:
		add_charges(floor(traveled_distance / 24.0))
		traveled_distance = fmod(traveled_distance, 24.0)


func add_charges(value: float):
	var old_energized: bool = charges >= 100.0

	charges = min(charges + value, 100.0)

	var new_energized: bool = charges >= 100.0

	if old_energized != new_energized:
		character_base.calculate_statistics()


func on_hit(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			return

	add_charges(6.0)


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return

	var auto_attack: bool

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			auto_attack = true
			break

	if !auto_attack:
		return
	
	add_charges(6.0)

	if charges < 100.0:
		return

	charges = 0.0

	timer.remaining_duration = 1.0
	
	var heal: float

	if character_base.character_data.ranged:
		heal = 6.0 + (89.29 - 6.0) / 17.0 * character_base.level
		heal += character_base.bonus_statistics.attack_damage * 0.06
		heal += character_base.total_statistics.ability_power * 0.03

	else:
		heal = 10.0 + (148.81 - 10.0) / 17.0 * character_base.level
		heal += character_base.bonus_statistics.attack_damage * 0.10
		heal += character_base.total_statistics.ability_power * 0.05

	Combat.apply_heal(character_base, heal)

	character_base.calculate_statistics()


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	if timer.remaining_duration <= 0.0:
		return

	if character_base.character_data.ranged:
		bonus_statistics.move_speed += 0.15 * raw_total_statistics.move_speed

	else:
		bonus_statistics.move_speed += 0.20 * raw_total_statistics.move_speed


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
