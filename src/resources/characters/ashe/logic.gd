extends CharacterLogic


var q_stack: Stack = Stack.new()
var q_active: bool
var q_duration: Cooldown = Cooldown.new()

var w_hits: Array[Stack]


func _physics_process(delta: float) -> void:
	if q_stack.cooldown.remaining_duration > 0:
		q_stack.cooldown.remaining_duration -= delta
		
		if q_stack.cooldown.remaining_duration <= 0:
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


func on_attack(damage_info: DamageInfo) -> void:
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
			
			if q_active:
				instance.amount *= 0.22 + 0.04 / 17.0 * character_base.level
		
	if q_active and has_auto_attack:
		_q_(damage_info)


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


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


func on_deal_projectile_hit(projectile: Projectile) -> void:
	for instance in projectile.damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.SKILL_W:
				if !character_base.is_enemy_team(projectile.damage_info.victim) or Combat.break_spell_shield(projectile.damage_info.victim):
					projectile.damage_info.damage_instances.clear()
					
					var stack_: Stack = Stack.new()

					stack_.target = projectile.damage_info.victim

					w_hits.append(stack_)
					
					return
				
				for stack: Stack in w_hits:
					if stack.target == projectile.damage_info.victim:
						projectile.damage_info.damage_instances.clear()
						return

				var stack: Stack = Stack.new()

				stack.target = projectile.damage_info.victim

				w_hits.append(stack)

				return

			SourceType.Type.SKILL_R:
				if !character_base.is_enemy_team(projectile.damage_info.victim) or Combat.break_spell_shield(projectile.damage_info.victim):
					projectile.damage_info.damage_instances.clear()
					return
				
				var stun_duration: float = 1.0 + 2.5 / 2800.0 * projectile.traveled_distance

				Combat.apply_crowd_control(projectile.damage_info.victim, CrowdControl.Type.STUN, stun_duration)

				var area: Area = Area.create_circle(projectile.damage_info.victim.global_position, 400.0)

				for target: CharacterBase in area.get_targets():
					if target == projectile.damage_info.victim:
						continue

					if target == character_base:
						continue
					
					if !character_base.is_enemy_team(target):
						continue
					
					if Combat.break_spell_shield(target):
						continue

					var damage_info: DamageInfo = projectile.damage_info.duplicate()

					damage_info.victim = target

					Combat.apply_damage(damage_info)

				return


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

	if !Combat.spend_mana(character_base, 30.0):
		return false
	
	_q()
	
	return true


func _q() -> void:
	character_base.auto_attack_cooldown.remaining_duration = 0.0
	
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
		if !damage_info.attacker.can_auto_attack():
			return
		
		await get_tree().create_timer(0.1 * (1 / character_base.total_statistics.attack_speed)).timeout
		Ingame.current.spawn_projectile(damage_info_, Projectile.Type.TARGET, character_base.total_statistics.attack_projectile_speed, 8.0)


func cast_w(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false
	
	if w_cooldown.remaining_duration > 0:
		return false
	
	if !Combat.spend_mana(character_base, max(0.0, 75.0 - 20.0 / 17.0 * character_base.level)):
		return false
	
	_w(cast_id)
	
	return true


func _w(cast_id: String) -> void:
	w_hits.clear()
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.25)
	
	w_cooldown.remaining_duration = max(0.0, 18.0 - 14.0 / 17.0 * character_base.level)
	
	var direction: Vector2 = (character_base.get_global_mouse_position() - character_base.global_position).normalized()
	
	await get_tree().create_timer(0.25).timeout
	
	if character_base.is_dead:
		return

	var damage_info: DamageInfo = DamageInfo.create(
		character_base,
		character_base,
		cast_id
	)

	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.SKILL_W,
		60.0 + 140.0 / 17.0 * character_base.level
		+ character_base.bonus_statistics.attack_damage,
		true,
		true
	)

	var perpendicular: Vector2 = direction.orthogonal()

	var arrow_count: int = floor(7.0 + 4.0 / 17.0 * character_base.level)

	var total_width: float = floor(75.0 + 48.0 / 17.0 * character_base.level)

	var angle_step: float = deg_to_rad(4.625)

	for i in range(arrow_count):
		var offset: float = lerp(
			- total_width * 0.5,
			total_width * 0.5,
			float(i) / float(max(1, arrow_count - 1))
		)

		var angle: float = (
			float(i) - float(arrow_count - 1) * 0.5
		) * angle_step

		Ingame.current.spawn_projectile(
			damage_info.duplicate(),
			Projectile.Type.LINEAR,
			2000.0,
			20.0,
			character_base.global_position
			+ direction * 75.0
			+ perpendicular * offset,
			direction.rotated(-angle),
			1200.0
		)

func cast_e(_cast_id: String) -> bool:
	return false


func cast_r(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false
	
	if r_cooldown.remaining_duration > 0:
		return false
	
	if !Combat.spend_mana(character_base, 100.0):
		return false
	
	_r(cast_id)
	
	return true


func _r(cast_id: String) -> void:
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.25)
	
	r_cooldown.start(max(0.0, 100.0 - 40.0 / 17.0 * character_base.level), Cooldown.Type.ULTIMATE, character_base.total_statistics)
	
	var direction: Vector2 = (character_base.get_global_mouse_position() - character_base.global_position).normalized()
	
	await get_tree().create_timer(0.25).timeout
	
	if character_base.is_dead:
		return

	var damage_info: DamageInfo = DamageInfo.create(character_base, character_base, cast_id)

	damage_info.add_damage_instance(
		DamageType.Type.MAGIC,
		SourceType.Type.SKILL_R,
		200.0 + 400.0 / 17.0 * character_base.level
		+ character_base.total_statistics.ability_power * 1.2,
		false,
		false
	)

	Ingame.current.spawn_projectile(
		damage_info,
		Projectile.Type.LINEAR,
		1500.0,
		130.0,
		character_base.global_position,
		direction,
		INF
	)
	
