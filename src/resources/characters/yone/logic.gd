extends CharacterLogic


var passive: bool
var q_stack: Stack = Stack.new()
var q_targets: Array[CharacterBase]

var e_targets: Array[Stack]
var e_duration: Cooldown = Cooldown.new()
var e_location: Vector2
var e_cast_id: String


func _physics_process(delta: float) -> void:
	if q_stack.cooldown.remaining_duration > 0:
		q_stack.cooldown.remaining_duration -= delta
		
		if q_stack.cooldown.remaining_duration <= 0:
			q_stack.stack = 0
	
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta
	
	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta
	
	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta
	
	if e_duration.remaining_duration > 0:
		e_duration.remaining_duration -= delta
		
		if e_duration.remaining_duration <= 0:
			if character_base.can_cast():
				_e2()
			
			else:
				e_duration.remaining_duration += delta
	
	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta


func on_attack(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_Q:
			return
	
	if passive:
		passive = false
		for i in range(damage_info.damage_instances.size() -1, -1, -1):
			var instance = damage_info.damage_instances[i]
			
			instance.amount *= 0.5
			
			damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.PASSIVE, instance.amount, true, true)
	
	else:
		passive = true


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.move_speed_multiplier += 0.1 + 0.2


func modify_total_statistics(base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	bonus_statistics.critical_chance += raw_total_statistics.critical_chance
	base_statistics.critical_damage_multiplier *= 1.8 / 2.0
	bonus_statistics.critical_damage_multiplier *= 1.8 / 2.0
	
	if bonus_statistics.critical_chance > 1.0:
		bonus_statistics.attack_damage += 50.0 * (bonus_statistics.critical_chance - 1.0)


func on_deal_damage(damage_info: DamageInfo) -> void:
	if e_duration.remaining_duration > 0:
		var target_stack: Stack
		
		for stack in e_targets:
			if stack.target == damage_info.victim:
				target_stack = stack
				break

		if !target_stack:
			target_stack = Stack.new()
			target_stack.target = damage_info.victim
			e_targets.append(target_stack)
		
		for instance in damage_info.damage_instances:
			target_stack.stack += (instance.amount * (0.25 + 0.1 / 17.0 * character_base.level))


func on_take_damage(_damage_info: DamageInfo) -> void:
	if character_base.is_dead:
		if e_duration.remaining_duration > 0:
			_e2()


func on_deal_projectile_hit(projectile: Projectile) -> void:
	_q3(projectile.damage_info)


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func cast_q(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_cooldown.remaining_duration > 0.0:
		return false
	
	if q_stack.stack < 2.0:
		_q(cast_id)
	
	else:
		_q2(cast_id)
	
	return true


func _q(cast_id: String):
	q_targets.clear()
	
	q_cooldown.remaining_duration = max(1.33, 4.0 - 2.67 * (character_base.total_statistics.attack_speed_multiplier / 1.11))
	
	var cast_time: float = max(0.175, 0.35 - 0.175 * (character_base.total_statistics.attack_speed_multiplier / 1.2))
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, cast_time)
	
	var mouse_pos: Vector2 = Ingame.current.get_global_mouse_position()
	
	var direction: Vector2 = (mouse_pos - character_base.global_position).normalized()

	var area: Area = Area.create_rectangle(
		character_base.global_position,
		direction.angle(),
		450.0,
		80.0,
		true,
		character_base,
		false,
		 direction * 225.0
	)
	
	Ingame.current.add_child(area)
	
	await get_tree().create_timer(cast_time).timeout
	
	if character_base.is_dead:
		area.queue_free()
		
		return
	
	var hit: bool = false
	
	for target in area.get_targets():
		if !character_base.is_enemy_team(target) or Combat.break_spell_shield(target):
			continue
		
		hit = true
		
		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)
		
		if q_targets.is_empty():
			character_base.on_attack(damage_info)
			
			damage_info.on_hit = true
		
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_Q, 25.0 + 100.0 / 17.0 * character_base.level + 1.1 * character_base.total_statistics.attack_damage, true, true)
		
		Combat.apply_damage(damage_info)
		
		q_targets.append(target)
	
	if hit:
		q_stack.stack = min(2.0, q_stack.stack + 1.0)
		
		q_stack.cooldown.remaining_duration = 6.0
	
	area.queue_free()


func _q2(cast_id: String):
	q_stack.stack = 0
	q_stack.cooldown.remaining_duration = 0
	
	q_targets.clear()
	
	q_cooldown.remaining_duration = max(1.33, 4.0 - 2.67 * (character_base.total_statistics.attack_speed_multiplier / 1.11))
	
	var cast_time: float = max(0.175, 0.35 - 0.175 * (character_base.total_statistics.attack_speed_multiplier / 1.2))
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, cast_time)
	
	var mouse_pos: Vector2 = Ingame.current.get_global_mouse_position()
	
	var direction: Vector2 = (mouse_pos - character_base.global_position).normalized()
	
	await get_tree().create_timer(cast_time).timeout

	if character_base.is_dead:
		return

	var area: Area = Area.create_circle(character_base.global_position, 100.0, true, character_base)
	
	Ingame.current.add_child(area)

	Combat.apply_forced_movement(character_base, (character_base.global_position + direction * 450.0), 1500.0)
	
	var damage_info: DamageInfo = DamageInfo.create(character_base, null, cast_id)
	
	var projectile: Projectile = Ingame.current.spawn_projectile(damage_info, Projectile.Type.LINEAR, 1500.0, 160.0)

	projectile.spawn_position = character_base.global_position
	projectile.direction = direction
	projectile.max_distance = 950.0
	projectile.pierce = true
	
	var timer: float = 450.0 / 1500.0
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, timer)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, timer)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, timer)
	
	while timer > 0:
		for target in area.get_targets():
			if !character_base.is_enemy_team(target):
				continue

			if Combat.break_spell_shield(target):
				continue
			
			damage_info.victim = target
			
			_q3(damage_info)

			Combat.apply_damage(damage_info)
		
		await get_tree().physics_frame
		
		timer -= get_physics_process_delta_time()
	
	area.queue_free()


func _q3(damage_info: DamageInfo) -> void:
	if q_targets.is_empty():
		damage_info.on_hit = true
		
		character_base.on_attack(damage_info)
	
	else:
		damage_info.on_hit = false
	
	if !q_targets.has(damage_info.victim):
		damage_info.damage_instances.clear()
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_Q, 25.0 + 100.0 / 17.0 * character_base.level + 1.1 * character_base.total_statistics.attack_damage, true, true)
		
		q_targets.append(damage_info.victim)
		
		Combat.apply_crowd_control(damage_info.victim, CrowdControl.Type.AIRBORNE, 0.75)
	
	else:
		damage_info.damage_instances.clear()


func cast_w(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if w_cooldown.remaining_duration > 0.0:
		return false
	
	_w(cast_id)
	
	return true


func _w(cast_id: String) -> void:
	w_cooldown.remaining_duration = max(6.0, 14.0 - 8.0 * (character_base.total_statistics.attack_speed_multiplier / 0.9455))
	
	var cast_time: float = max(0.19, 0.5 - 0.31 * (character_base.total_statistics.attack_speed_multiplier / 1.05))
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, cast_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, cast_time)
	
	var radius: float = 600.0 + character_base.character_collision_shape_radius
	var points: PackedVector2Array

	points.append(Vector2.ZERO)

	for i in range(9):
		var angle: float = deg_to_rad(-40.0 + 80.0 * i / 8.0)

		points.append(Vector2(
			cos(angle) * radius,
			sin(angle) * radius
		))
	
	var area: Area = Area.create_polygon(
		character_base.global_position,
		(Ingame.current.get_global_mouse_position() - character_base.global_position).angle(),
		points,
		true,
		character_base
	)
	
	Ingame.current.spawn_area(area)
	
	await get_tree().create_timer(cast_time).timeout
	
	if character_base.is_dead:
		area.queue_free()
		
		return
	
	var hit: int = 0
	
	for target in area.get_targets():
		if !target.is_enemy_team(character_base) or Combat.break_spell_shield(target):
			continue
		
		hit += 1
		
		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)
		
		var amount: float = 5.0 + 20.0 / 17.0 * character_base.level + (0.08 + 0.04 / 17.0 * character_base.level) * target.total_statistics.health
		
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_W, amount, false, false)
		damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.SKILL_W, amount, false, false)
		
		Combat.apply_damage(damage_info)
	
	if hit:
		var amount: float = 80.0 + 100.0 / 17.0 * character_base.level + 1.3 * character_base.bonus_statistics.attack_damage
		
		if hit > 1:
			amount *= 1.0 + (hit - 1.0) / 2.0
		
		Combat.apply_barrier(character_base, amount, 1.5)
	
	area.queue_free()


func cast_e(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if e_duration.remaining_duration > 0:
		if e_duration.remaining_duration <= 4.5:
			_e2()

		return true

	if e_cooldown.remaining_duration > 0:
		return false

	e_cast_id = cast_id
	_e()

	return true


func _e() -> void:
	e_cooldown.start(max(0.0, 22.0 - 12.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	e_duration.remaining_duration = 5.0
	
	character_base.is_ghost = true
	
	var time: float = 300.0 / 1200.0
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, time)
	
	Combat.apply_forced_movement(character_base, character_base.global_position + (Ingame.current.get_global_mouse_position() - character_base.global_position).normalized() * 300.0, 1200.0)
	
	e_location = character_base.global_position - ((Ingame.current.get_global_mouse_position() - character_base.global_position).normalized() * 300.0)
	
	character_base.calculate_statistics()


func _e2() -> void:
	e_duration.remaining_duration = 0
	
	character_base.is_ghost = false
	
	var time: float = character_base.global_position.distance_to(e_location) / 1200.0
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_SPELL, time)
	Combat.apply_status(character_base, Status.Type.UNSTOPPABLE, time)

	Combat.apply_forced_movement(character_base, e_location, 1200.0)

	for stack in e_targets:
		if stack.target.is_dead or Combat.break_spell_shield(stack.target):
			continue

		var damage_info: DamageInfo = DamageInfo.create(character_base, stack.target, e_cast_id)

		damage_info.add_damage_instance(DamageType.Type.TRUE, SourceType.Type.SKILL_E, stack.stack, false, false)

		Combat.apply_damage(damage_info)

	e_targets.clear()

	character_base.calculate_statistics()


func cast_r(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if r_cooldown.remaining_duration > 0.0:
		return false
	
	_r(cast_id)
	
	return true


func _r(cast_id: String) -> void:
	r_cooldown.start(max(0.0, 120.0 - 40.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.75)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.75)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.75)
	Combat.apply_status(character_base, Status.Type.CANNOT_SPELL, 0.75)
	
	var mouse_pos: Vector2 = Ingame.current.get_global_mouse_position()
	
	var direction: Vector2 = (mouse_pos - character_base.global_position).normalized()

	var area: Area = Area.create_rectangle(
		character_base.global_position + direction * 500.0,
		direction.angle(),
		1000.0,
		225.0,
		true
	)
	
	Ingame.current.add_child(area)
	
	await get_tree().create_timer(0.75).timeout
	
	if character_base.is_dead:
		area.queue_free()
		
		return
	
	var targets: Array[CharacterBase]
	var farthest_projection: float = -INF
	var last_target: CharacterBase
	var blink_position: Vector2 = character_base.global_position + direction * 1000.0
	
	for target in area.get_targets():
		if !character_base.is_enemy_team(target) or Combat.break_spell_shield(target):
			continue
		
		var projection: float = (target.global_position - character_base.global_position).dot(direction)

		if projection > farthest_projection:
			farthest_projection = projection
			last_target = target
		
		targets.append(target)
		
		Combat.apply_crowd_control(target, CrowdControl.Type.STUN, 1.0)
	
	if last_target:
		blink_position = last_target.global_position + direction * 200.0
		
	character_base.global_position = blink_position
	character_base.is_moving = false
	character_base.forced_movement = null
	
	await get_tree().create_timer(0.3).timeout
	
	
	for target in targets:
		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)
		var damage: float = 100.0 + 200.0 / 17.0 * character_base.level + 0.8 * character_base.bonus_statistics.attack_damage
		
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_R, damage, false, false)
		
		damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.SKILL_R, damage, false, false)
		
		Combat.apply_damage(damage_info)
		
		Combat.apply_crowd_control(target, CrowdControl.Type.AIRBORNE, 0.75)
		
		Combat.apply_forced_movement(target, blink_position, target.global_position.distance_to(blink_position) / 0.75)
	
	area.queue_free()
