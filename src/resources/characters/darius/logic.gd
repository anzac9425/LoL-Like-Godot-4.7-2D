extends CharacterLogic


var passive_instances: Array[Stack]
var passive_full: int

var w_active: bool
var w_active_cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_instances:
		for i in range(passive_instances.size() - 1, -1, -1):
			var instance: Stack = passive_instances[i]
			
			instance.cooldown.remaining_duration -= delta
			
			if instance.cooldown.remaining_duration <= 0.0:
				if instance.stack == 5:
					passive_full -= 1

					if passive_full == 0:
						character_base.calculate_statistics()

				passive_instances.remove_at(i)

				continue
			
			var passive_damage_info: DamageInfo = DamageInfo.create(character_base, instance.target, instance.cast_ids[0], true)
			
			passive_damage_info.add_damage_instance(
				DamageType.Type.PHYSICAL,
				SourceType.Type.PASSIVE,
				(13.0 + character_base.level + 0.3 * character_base.bonus_statistics.attack_damage)
				* instance.stack * delta / 5,
				false,
				false
			)

			Combat.apply_damage(passive_damage_info)
	
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta
	
	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta
	
	if w_active_cooldown.remaining_duration > 0:
		w_active_cooldown.remaining_duration -= delta
		
		if w_active_cooldown.remaining_duration <= 0:
			w_active = false
			
			character_base.calculate_statistics()
			
	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta
	
	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta


func apply_passive(target: CharacterBase):
	var passive_instance: Stack

	for instance in passive_instances:
		if instance.target == target:
			passive_instance = instance
			break

	if !passive_instance:
		passive_instance = Stack.new()
		passive_instance.target = target
		passive_instance.cast_ids = [DamageInfo.generate_cast_id()]

		passive_instances.append(passive_instance)
	
	if target.is_dead:
		if passive_instance.stack != 5:
			passive_instance.stack = 5
			passive_full += 1
			character_base.calculate_statistics()

		passive_instance.cooldown.remaining_duration = 5.0
		return

	elif passive_full > 0:
		if passive_instance.stack != 5:
			passive_instance.stack = 5
			passive_full += 1
	
	else:
		if passive_instance.stack < 5:
			passive_instance.stack += 1

			if passive_instance.stack == 5:
				passive_full += 1
				character_base.calculate_statistics()

	passive_instance.cooldown.remaining_duration = 5.0


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
	
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			if w_active:
				w_active = false
				
				w_active_cooldown.remaining_duration = 0.0
				
				w_cooldown.start(5.0, Cooldown.Type.SKILL, character_base.total_statistics)
				
				damage_info.add_damage_instance(
					DamageType.Type.PHYSICAL,
					SourceType.Type.SKILL_W,
					(2.4 + 0.2 / 17.0 * character_base.level)
					* character_base.total_statistics.attack_damage,
					true,
					true
				)
				
				character_base.calculate_statistics()
				
				break


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if passive_full > 0:
		bonus_statistics.attack_damage += 30.0 + 250.0 / 17.0 * character_base.level
		
	if w_active:
		bonus_statistics.attack_range += 25
	
	bonus_statistics.armor_penetration_multiplier += 0.2 + 0.2 / 17.0 * character_base.level


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.AUTO_ATTACK, SourceType.Type.SKILL_R:
				apply_passive(damage_info.victim)

			SourceType.Type.SKILL_W:
				if Combat.break_spell_shield(damage_info.victim):
					continue
				
				Combat.apply_crowd_control(damage_info.victim, CrowdControl.Type.SLOW, 1.0, 0.9)
				
				if damage_info.victim.is_dead:
					w_cooldown.remaining_duration *= 0.5
				
				break


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func cast_q(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_cooldown.remaining_duration > 0.0:
		return false
	
	if !Combat.spend_mana(character_base, 25.0 + 20.0 / 17.0 * character_base.level):
		return false
	
	_q(cast_id)
	
	return true


func _q(cast_id: String) -> void:
	q_cooldown.start(max(0.0, 9.0 - (4.0 / 17.0 * character_base.level)), Cooldown.Type.SKILL, character_base.total_statistics)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.75)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.75)

	var outer_area: Area = Area.create_circle(character_base.global_position, 425.0, true, character_base)

	var inner_area: Area = Area.create_circle(character_base.global_position, 205.0, true, character_base)

	Ingame.current.spawn_area(outer_area)
	Ingame.current.spawn_area(inner_area)

	await get_tree().create_timer(0.75).timeout

	if character_base.is_dead:
		outer_area.queue_free()
		inner_area.queue_free()
		return

	var base_damage: float = (
		50.0 + 120.0 / 17.0 * character_base.level
		+ (1.0 + 0.4 / 17.0 * character_base.level) * character_base.total_statistics.attack_damage
	)
	
	var targets: Array[CharacterBase] = outer_area.get_targets()
	var heal_count: int = 0

	for target in targets:
		if !character_base.is_enemy_team(target):
			continue
		
		if Combat.break_spell_shield(target):
			continue
		
		var is_inner: bool
		var damage: float = base_damage
		
		if character_base.global_position.distance_to(target.global_position) + target.character_collision_shape_radius < 270:
			damage *= 0.35
			is_inner = true

		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)

		damage_info.add_damage_instance(
			DamageType.Type.PHYSICAL,
			SourceType.Type.SKILL_Q,
			damage,
			false,
			false
		)

		Combat.apply_damage(damage_info)
		
		if !is_inner:
			heal_count += 1
			
			apply_passive(damage_info.victim)
			
	Combat.apply_heal(character_base, heal_count * (0.17 * (character_base.total_statistics.health - character_base.current_health)))
		
	outer_area.queue_free()
	inner_area.queue_free()


func cast_w(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if w_cooldown.remaining_duration > 0.0:
		return false
	
	if !Combat.spend_mana(character_base, 40.0):
		return false
	
	_w()
	
	return true


func _w() -> void:
	w_active_cooldown.remaining_duration = 4.0
	
	w_active = true
	
	character_base.auto_attack_cooldown.remaining_duration = 0.0
	
	character_base.calculate_statistics()


func cast_e(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if e_cooldown.remaining_duration > 0.0:
		return false
	
	if !Combat.spend_mana(character_base, max(0.0, 70 - 40.0 / 17.0 * character_base.level)):
		return false
	
	_e()
	
	return true


func _e() -> void:
	e_cooldown.start(max(0.0, 26.0 - 10.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)

	Combat.apply_status(character_base,Status.Type.CANNOT_MOVE, 0.65)
	Combat.apply_status(character_base,Status.Type.CANNOT_AUTO_ATTACK, 0.65)
	Combat.apply_status(character_base,Status.Type.CANNOT_CAST, 0.65)
	
	var radius: float = 535.0 + character_base.character_collision_shape_radius
	var points: PackedVector2Array = PackedVector2Array()

	points.append(Vector2.ZERO)

	for i in range(6):
		var angle: float = deg_to_rad( -25.0 + 50.0 * i / 5.0)
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

	await get_tree().create_timer(0.25).timeout

	if character_base.is_dead:
		return
	
	var targets: Array[CharacterBase]

	for target in area.get_targets():
		if !character_base.is_enemy_team(target):
			continue
		
		if Combat.break_spell_shield(target):
			continue

		var destination: Vector2 = (
			character_base.global_position
			+ (target.global_position - character_base.global_position).normalized()
			* 125.0
		)

		Combat.apply_forced_movement(
			target,
			destination,
			destination.distance_to(target.global_position) / 0.4
		)
		
		Combat.apply_crowd_control(target, CrowdControl.Type.AIRBORNE, 0.75)
		
		targets.append(target)
	
	area.queue_free()
	
	await get_tree().create_timer(0.75).timeout
	
	for target in targets:
		Combat.apply_crowd_control(target, CrowdControl.Type.SLOW, 1.0, 0.4)
	


func cast_r(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if r_cooldown.remaining_duration > 0.0:
		return false
	
	if !Combat.spend_mana(character_base, max(0.0, 100.0 - 100.0 / 17.0 * character_base.level)):
		return false
	
	_r(cast_id)
	
	return true


func _r(cast_id: String) -> void:
	var target: CharacterBase = Ingame.current.get_target_at_mouse_position()
	
	if !target:
		return
		
	if character_base.global_position.distance_to(target.global_position) > 2460.0 + character_base.character_collision_shape_radius + target.character_collision_shape_radius:
		return
		
	if target == character_base:
		return
	
	if !character_base.is_enemy_team(target):
		return

	if target.is_dead:
		return
	
	if !target.can_be_targeted():
		return
	
	r_cooldown.start(max(0.0, 120.0 - 40.0 / 17.0 * character_base.level), Cooldown.Type.ULTIMATE, character_base.total_statistics)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.36)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.36)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.36)
	
	var direction: Vector2 = (target.global_position - character_base.global_position).normalized()

	var destination: Vector2 = (
		target.global_position
		- direction * (target.character_collision_shape_radius + character_base.character_collision_shape_radius)
	)
	
	Combat.apply_forced_movement(character_base, destination, character_base.global_position.distance_to(destination) / 0.36)

	await get_tree().create_timer(0.36).timeout
	
	if Combat.break_spell_shield(target):
		return
	
	if character_base.is_dead:
		r_cooldown.remaining_duration = 0.0
		return

	if target.is_dead:
		r_cooldown.remaining_duration = 0.0
		return

	if !target.can_be_targeted():
		r_cooldown.remaining_duration = 0.0
		return
	
	if !character_base.can_cast():
		r_cooldown.remaining_duration = 0.0
		return
	
	var stack: float

	for instance in passive_instances:
		if instance.target == target:
			stack = instance.stack
			break
	
	var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)
	
	damage_info.add_damage_instance(
		DamageType.Type.TRUE,
		SourceType.Type.SKILL_R,
		(125.0 + 250.0 / 17.0 * character_base.level
		+ 0.75 * character_base.total_statistics.attack_damage)
		* (1.0 + 0.2 * stack),
		false,
		false
	)
	
	Combat.apply_damage(damage_info)
	
	if target.is_dead:
		r_cooldown.remaining_duration = 0.0
		apply_passive(target)
