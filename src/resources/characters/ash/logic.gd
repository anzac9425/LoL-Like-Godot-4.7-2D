extends CharacterLogic


var q_cooldown: Cooldown = Cooldown.new()
var q_stack: Stack = Stack.new()
var q_active: bool
var q_duration: Cooldown = Cooldown.new()

var w_cooldown: Cooldown = Cooldown.new()

var e_cooldown: Cooldown = Cooldown.new()

var r_cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta

	if q_stack.stack > 0.0:
		if q_stack.cooldown.remaining_duration > 0.0:
			q_stack.cooldown.remaining_duration -= delta
		else:
			q_stack.stack = max(0.0, q_stack.stack - delta)

	if q_duration.remaining_duration > 0:
		q_duration.remaining_duration -= delta

		if q_duration.remaining_duration <= 0:
			q_active = false

			character_base.calculate_statistics()

	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta

	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta

	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return

	var has_auto_attack: bool

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			has_auto_attack = true
			instance.allow_critical = false

			if character_base.total_statistics.critical_chance:
				damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.PASSIVE, instance.amount * character_base.total_statistics.critical_chance * (character_base.total_statistics.critical_damage_multiplier - 1.0), false, true)

			if !q_active:
				q_stack.stack = min(4.0, 1.0 + q_stack.stack)
				q_stack.cooldown.remaining_duration = 4.0
			else:
				instance.amount *= 0.22 + 0.04 / 17.0 * character_base.level

	if q_active and has_auto_attack:
		_q_(damage_info)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if q_active:
		bonus_statistics.attack_speed_multiplier += 0.2 + 0.4 / 17.0 * character_base.level


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	var passive: bool

	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.AUTO_ATTACK:
				passive = true

			SourceType.Type.SKILL_Q:
				passive = true

			SourceType.Type.SKILL_W:
				passive = true

			SourceType.Type.SKILL_E:
				passive = true

			SourceType.Type.SKILL_R:
				passive = true

	if !passive:
		return

	var crit: float = 1.0

	if damage_info.was_crit:
		crit = character_base.total_statistics.critical_damage_multiplier

	Combat.apply_crowd_control(damage_info.victim, CrowdControl.Type.SLOW, 2.0, crit * (0.2 + 0.1 / 17.0 * character_base.level))

func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func cast_q(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_active:
		return false

	if q_stack.stack < 4.0:
		return false

	_q()

	return true


func _q() -> void:
	q_stack.stack = 0
	q_stack.cooldown.remaining_duration = 0

	q_duration.remaining_duration = 6.0

	q_active = true

	character_base.calculate_statistics()


func _q_(damage_info: DamageInfo) -> void:
	var damage_info_: DamageInfo = DamageInfo.create(damage_info.attacker, damage_info.victim, damage_info.cast_id)
	damage_info_.on_hit = false

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			damage_info_.add_damage_instance(
				instance.damage_type,
				SourceType.Type.SKILL_Q,
				instance.amount,
				instance.allow_critical,
				instance.allow_lifesteal
			)

	for i in range(4):
		await get_tree().create_timer(0.1 * (1.0 / character_base.total_statistics.attack_speed)).timeout

		if damage_info.attacker.is_dead or damage_info.victim.is_dead or !damage_info.victim.can_be_targeted() or !damage_info.attacker.can_auto_attack():
			return

		Ingame.current.spawn_projectile(damage_info_.duplicate(), Projectile.Type.TARGET, character_base.total_statistics.attack_projectile_speed, 8.0)


func cast_w(_cast_id: String) -> bool:
	return false


func cast_e(_cast_id: String) -> bool:
	return false


func cast_r(_cast_id: String) -> bool:
	return false
