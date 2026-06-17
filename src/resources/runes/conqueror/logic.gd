extends CharacterLogic

var stacks: int
var timer: Cooldown = Cooldown.new()

var cast_ids: Array[String]
var cast_timers: Array[float]


func _physics_process(delta: float) -> void:
	if timer.remaining_duration > 0.0:
		timer.remaining_duration -= delta

		if timer.remaining_duration <= 0.0:
			stacks = 0

			character_base.calculate_statistics()
	
	if cast_ids:
		for i in range(cast_ids.size() - 1, -1, -1):
			cast_timers[i] -= delta

			if cast_timers[i] <= 0.0:
				cast_ids.remove_at(i)
				cast_timers.remove_at(i)


func add_stacks(value: int) -> void:
	var old_stacks: int = stacks

	stacks = min(stacks + value, 12)

	timer.remaining_duration = 5.0

	if old_stacks != stacks:
		character_base.calculate_statistics()


func on_hit(damage_info: DamageInfo) -> void:
	var auto_attack: bool

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			auto_attack = true
			break

	if auto_attack:
		add_stacks(
			1 if character_base.character_data.ranged else 2
		)
		return

	if damage_info.cast_id.is_empty():
		return

	for id in cast_ids:
		if id == damage_info.cast_id:
			return

	cast_ids.append(damage_info.cast_id)
	cast_timers.append(4.0)

	add_stacks(2)


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.adaptive_force += (1.08 + (2.56 - 1.08) / 17.0 * character_base.level) * stacks


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if stacks < 12:
		return

	var damage: float = 0.0

	for instance in damage_info.damage_instances:
		damage += instance.amount

	if character_base.character_data.ranged:
		Combat.apply_heal(character_base, damage * 0.05)

	else:
		Combat.apply_heal(character_base, damage * 0.08)


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
