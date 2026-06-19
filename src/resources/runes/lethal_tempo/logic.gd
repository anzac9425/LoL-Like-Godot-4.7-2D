extends CharacterLogic


var stacks: int = 0

var active_timer: float = 0.0
var decay_timer: float = 0.0


func _physics_process(delta):
	if active_timer > 0.0:
		active_timer -= delta

		if active_timer <= 0.0:
			decay_timer = 0.5

	elif stacks > 0:
		decay_timer -= delta

		if decay_timer <= 0.0:
			stacks -= 1
			decay_timer = 0.5

			character_base.calculate_statistics()


func add_stack():
	var old_stacks = stacks

	stacks = min(stacks + 1, 6)

	active_timer = 6.0
	decay_timer = 0.0

	if old_stacks != stacks:
		character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


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
	
	add_stack()
	
	if stacks < 6:
		return

	var damage: float

	if character_base.character_data.ranged:
		damage = 6.0 + (26.12 - 6.0) / 17.0 * character_base.level

		damage += character_base.bonus_statistics.attack_speed_multiplier * 100.0 * 0.66

	else:
		damage = 9.0 + (32.47 - 9.0) / 17.0 * character_base.level

		damage += character_base.bonus_statistics.attack_speed_multiplier * 100.0 * 1.0

	var damage_type: DamageType.Type

	if character_base.bonus_statistics.attack_damage >= character_base.bonus_statistics.ability_power:
		damage_type = DamageType.Type.PHYSICAL

	else:
		damage_type = DamageType.Type.MAGIC

	damage_info.add_damage_instance(
		damage_type,
		SourceType.Type.RUNE,
		damage,
		false,
		false
	)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if character_base.character_data.ranged:
		bonus_statistics.attack_speed_multiplier += stacks * 0.048
	
	else:
		bonus_statistics.attack_speed_multiplier += stacks * 0.06


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
