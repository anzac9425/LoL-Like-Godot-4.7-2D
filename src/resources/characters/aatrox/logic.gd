extends CharacterLogic


var passive_ready: bool
var passive_cooldown: Cooldown = Cooldown.new()

var q_index: int
var q_casting: bool
var q_rotation: float
var q_recast: Cooldown = Cooldown.new()

var r_active: bool
var r_duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_cooldown.remaining_duration > 0.0:
		passive_cooldown.remaining_duration -= delta

		if passive_cooldown.remaining_duration <= 0.0:
			passive_ready = true
			
			character_base.calculate_statistics()
		
	if q_cooldown.remaining_duration > 0.0:
		q_cooldown.remaining_duration -= delta

	if q_recast.remaining_duration > 0.0:
		q_recast.remaining_duration -= delta

		if q_recast.remaining_duration <= 0.0:
			q_index = 0
			
			q_cooldown.start(max(0.0, 14.0 - 8.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	if w_cooldown.remaining_duration > 0.0:
		w_cooldown.remaining_duration -= delta
	
	if e_cooldown.remaining_duration > 0.0:
		e_cooldown.remaining_duration -= delta
	
	if r_cooldown.remaining_duration > 0.0:
		r_cooldown.remaining_duration -= delta
	
	if r_duration.remaining_duration > 0.0:
		r_duration.remaining_duration -= delta

		if r_duration.remaining_duration <= 0.0:
			r_active = false
			character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
		
	if passive_ready:
		var has_auto_attack: bool

		for instance in damage_info.damage_instances:
			if instance.source_type == SourceType.Type.AUTO_ATTACK:
				has_auto_attack = true
				break
		
		if has_auto_attack:
			passive_ready = false
			passive_cooldown.remaining_duration = max(0.0, 22.0 - 10.0 / 17.0 * character_base.level)
			
			damage_info.add_damage_instance(
				DamageType.Type.MAGIC,
				SourceType.Type.PASSIVE,
				damage_info.victim.total_statistics.health * (0.04 + 0.06 / 17.0 * character_base.level),
				true,
				true
			)
			
			character_base.calculate_statistics()


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.omnivamp = 0.16 + 0.00011 * bonus_statistics.health
	
	if passive_ready:
		bonus_statistics.attack_range += 50


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	if r_active:
		bonus_statistics.attack_damage += (0.20 + (0.20 / 17.0 * character_base.level)) * raw_total_statistics.attack_damage
		
		bonus_statistics.heal_shield_power_multiplier += 0.50 + (0.50 / 17.0 * character_base.level)
		
		bonus_statistics.move_speed += (0.60 + (0.40 / 17.0 * character_base.level)) * raw_total_statistics.move_speed


func on_deal_damage(damage_info: DamageInfo) -> void:
	var reduce_cooldown: bool
	
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.PASSIVE:
			Combat.apply_heal(character_base, instance.amount)
		
		else:
			reduce_cooldown = true
	
	if reduce_cooldown:
		passive_cooldown.remaining_duration -= 2.0
	
	if damage_info.victim.is_dead and r_active:
		r_duration.remaining_duration += 5.0


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(projectile: Projectile) -> void:
	for instance in projectile.damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_W:
			var target: CharacterBase = projectile.damage_info.victim
			var damage_info: DamageInfo = projectile.damage_info
			
			if Combat.break_spell_shield(target):
				return
			
			var area: Area = Area.create_polygon(
				projectile.damage_info.victim.global_position,
				(target.global_position - character_base.global_position).angle(),
				PackedVector2Array([
					Vector2(-200, -175),
					Vector2(-200, 175),
					Vector2(500, 300),
					Vector2(500, -300),
				]),
				true
			)
			
			Ingame.current.spawn_area(area)
			
			Combat.apply_crowd_control(
				target,
				CrowdControl.Type.SLOW,
				1.5,
				0.25 + (0.1 / 17.0 * character_base.level)
			)
			
			await get_tree().create_timer(1.5).timeout
			
			if !is_instance_valid(area):
				return
			
			if target.is_dead:
				area.queue_free()
				return
			
			if target in area.get_targets():
				Combat.apply_forced_movement(target, area.global_position, area.global_position.distance_to(target.global_position) / 0.1)
				
				var second_damage_info: DamageInfo = DamageInfo.create(damage_info.attacker, damage_info.victim, damage_info.cast_id)
				
				second_damage_info.add_damage_instance(
					DamageType.Type.PHYSICAL,
					SourceType.Type.SKILL_W,
					30.0
					+ (40.0 / 17.0 * character_base.level)
					+ 0.4 * character_base.total_statistics.attack_damage,
					false,
					false
				)
				
				Combat.apply_damage(second_damage_info)
			
			area.queue_free()
			
			break


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func cast_q(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_casting:
		return false

	if q_index == 0 and q_cooldown.remaining_duration > 0.0:
		return false
	
	_q(cast_id)
	
	return true
	

func _q(cast_id: String) -> void:
	q_rotation = (
		Ingame.current.get_global_mouse_position()
		- character_base.global_position
	).angle()

	var base_damage: float = (
		10.0
		+ (60.0 / 17.0 * character_base.level)
		+ (0.6 + 0.3 / 17.0 * character_base.level)
		* character_base.total_statistics.attack_damage
	)

	q_casting = true

	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.6)

	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.6)

	var area: Area
	var sweet_area: Area
	var damage_multiplier: float
	var next_index: int

	match q_index:
		0:
			q_recast.remaining_duration = 4.0

			area = Area.create_rectangle(
				character_base.global_position,
				q_rotation,
				625.0,
				180.0,
				true,
				character_base,
				false,
				Vector2.RIGHT.rotated(q_rotation) * 312.5
			)

			sweet_area = Area.create_rectangle(
				character_base.global_position,
				q_rotation,
				160.0,
				180.0,
				true,
				character_base,
				false,
				Vector2.RIGHT.rotated(q_rotation) * 545.0
			)

			damage_multiplier = 1.0
			next_index = 1

		1:
			q_recast.remaining_duration = 4.0

			var points: PackedVector2Array = PackedVector2Array([
				Vector2(-100, -150),
				Vector2(-100, 150),
				Vector2(475, 250),
				Vector2(475, -250),
			])

			var sweet_points: PackedVector2Array = PackedVector2Array([
				Vector2(315, -205),
				Vector2(315, 205),
				Vector2(475, 250),
				Vector2(475, -250),
			])

			area = Area.create_polygon(
				character_base.global_position,
				q_rotation,
				points,
				true,
				character_base,
				false
			)

			sweet_area = Area.create_polygon(
				character_base.global_position,
				q_rotation,
				sweet_points,
				true,
				character_base,
				false
			)

			damage_multiplier = 1.25
			next_index = 2
			
			cast_id = DamageInfo.generate_cast_id()

		2:
			area = Area.create_circle(
				character_base.global_position
				+ Vector2.RIGHT.rotated(q_rotation) * 200.0,
				300.0,
				true,
				character_base,
				false,
				Vector2.RIGHT.rotated(q_rotation) * 200.0
			)

			sweet_area = Area.create_circle(
				character_base.global_position
				+ Vector2.RIGHT.rotated(q_rotation) * 200.0,
				180.0,
				true,
				character_base,
				false,
				Vector2.RIGHT.rotated(q_rotation) * 200.0
			)

			damage_multiplier = 1.5
			next_index = 0
			
			cast_id = DamageInfo.generate_cast_id()

	Ingame.current.spawn_area(area)
	Ingame.current.spawn_area(sweet_area)
	
	await get_tree().create_timer(0.6).timeout

	if character_base.is_dead:
		q_casting = false
		area.queue_free()
		sweet_area.queue_free()
		return

	var sweet_targets: Array[CharacterBase] = sweet_area.get_targets()

	for target in area.get_targets():
		if !character_base.is_enemy_team(target):
			continue
		
		if Combat.break_spell_shield(target):
			continue

		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)

		var damage: float = base_damage * damage_multiplier

		if target in sweet_targets:
			damage *= 1.75

			Combat.apply_crowd_control(target, CrowdControl.Type.AIRBORNE, 0.25)
			
			passive_cooldown.remaining_duration -= 2.0

		damage_info.add_damage_instance(
			DamageType.Type.PHYSICAL,
			SourceType.Type.SKILL_Q,
			damage,
			false,
			false
		)

		Combat.apply_damage(damage_info)

	area.queue_free()
	sweet_area.queue_free()

	if q_index == 2:
		q_index = 0
		q_recast.remaining_duration = 0.0
		q_cooldown.start(max(0.0, 14.0 - 8.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
		q_casting = false
	
	else:
		q_index = next_index
		await get_tree().create_timer(0.4).timeout
		q_casting = false


func cast_w(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if w_cooldown.remaining_duration > 0.0:
		return false
	
	_w(cast_id)
	
	return true


func _w(cast_id: String) -> void:
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)
	
	var direction: Vector2 = (Ingame.current.get_global_mouse_position() - character_base.global_position).normalized()
	
	w_cooldown.start(max(0.0, 20.0 - (6.0 / 17.0 * character_base.level)), Cooldown.Type.SKILL, character_base.total_statistics)

	await get_tree().create_timer(0.25).timeout

	if character_base.is_dead:
		return

	var damage_info: DamageInfo = DamageInfo.create(character_base, null, cast_id)

	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.SKILL_W,
		30.0
		+ (40.0 / 17.0 * character_base.level)
		+ 0.4 * character_base.total_statistics.attack_damage,
		false,
		false
	)

	var projectile: Projectile = (
		Ingame.current.spawn_projectile(
			damage_info,
			Projectile.Type.LINEAR,
			1800.0,
			80.0
		)
	)

	projectile.direction = direction

	projectile.max_distance = 825.0


func cast_e(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if e_cooldown.remaining_duration > 0.0:
		return false
	
	_e()
	
	return true


func _e() -> void:
	e_cooldown.start(max(0.0, 9.0 - (4.0 / 17.0 * character_base.level)), Cooldown.Type.SKILL, character_base.total_statistics)

	var direction: Vector2 = (Ingame.current.get_global_mouse_position() - character_base.global_position).normalized()

	var mouse_pos: Vector2 = Ingame.current.get_global_mouse_position()

	var distance: float = min(character_base.global_position.distance_to(mouse_pos), 300.0)

	Combat.apply_forced_movement(character_base, character_base.global_position + direction * distance, 800.0)
	
	character_base.auto_attack_cooldown.remaining_duration = 0.0


func cast_r(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if r_cooldown.remaining_duration > 0.0:
		return false
	
	_r()
	
	return true


func _r() -> void:
	r_cooldown.start(max(0.0, 120.0 - (40.0 / 17.0 * character_base.level)), Cooldown.Type.ULTIMATE, character_base.total_statistics)

	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)

	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)

	await get_tree().create_timer(0.25).timeout

	if character_base.is_dead:
		return

	r_active = true

	r_duration.remaining_duration = 10.0

	character_base.calculate_statistics()
