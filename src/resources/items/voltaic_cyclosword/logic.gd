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

func on_attack(_damage_info: DamageInfo) -> void:
	add_charges(6.0)


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return

	var skill: bool

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_Q or instance.source_type == SourceType.Type.SKILL_W or instance.source_type == SourceType.Type.SKILL_E or instance.source_type == SourceType.Type.SKILL_R:
			skill = true
			break

	if !skill:
		return
	
	if charges < 100.0:
		return
	
	charges = 0.0
	
	timer.remaining_duration = 4.0
	
	if character_base.character_data.ranged:
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM, 0.09 * damage_info.victim.current_health, false, false)
	
	else:
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM, 0.06 * damage_info.victim.current_health, false, false)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if timer.remaining_duration <= 0.0:
		return

	if character_base.character_data.ranged:
		bonus_statistics.armor_penetration_flat += 15.0

	else:
		bonus_statistics.armor_penetration_flat += 12.0


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


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
