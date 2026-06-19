extends CharacterLogic


var passive_amount: int
var passive_cooldown: Cooldown = Cooldown.new()

var q_cooldown: Cooldown = Cooldown.new()

var w_cooldown: Cooldown = Cooldown.new()

var e_active: bool
var e_cooldown: Cooldown = Cooldown.new()
var e_active_cooldown: Cooldown = Cooldown.new()

var r_active: bool
var r_cooldown: Cooldown = Cooldown.new()
var r_active_cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_cooldown.remaining_duration > 0:
		passive_cooldown.remaining_duration -= delta
		
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta
	
	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta
	
	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta
	
	if e_active_cooldown.remaining_duration > 0:
		e_active_cooldown.remaining_duration -= delta

		if e_active_cooldown.remaining_duration <= 0.0:
			e_active = false
	
	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta
	
	if r_active_cooldown.remaining_duration > 0:
		r_active_cooldown.remaining_duration -= delta

		if r_active_cooldown.remaining_duration <= 0:
			_cast_r2()


func add_passive() -> void:
	if r_active:
		passive_amount += 1
		
	else:
		passive_amount = min(passive_amount + 1, 3)

	character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
	
	if !passive_amount:
		return
	
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			if r_active:
				Combat.apply_heal(character_base, 0.05 * (character_base.total_statistics.health - character_base.current_health))
			else:
				passive_amount -= 1
			
			damage_info.add_damage_instance(
				DamageType.Type.MAGIC,
				SourceType.Type.PASSIVE,
				1.3 * character_base.total_statistics.attack_damage
				+ 0.3 * character_base.total_statistics.ability_power,
				true,
				true
			)
			
			var area: Area = Area.create_circle(damage_info.attacker.global_position, 300.0, true)
			
			Ingame.current.add_child(area)
			
			for target in area.get_targets():
				if target == damage_info.victim:
					continue
				
				if !character_base.is_enemy_team(target):
					continue
				
				var splash_damage_info: DamageInfo = DamageInfo.create(character_base, target, damage_info.cast_id)

				splash_damage_info.add_damage_instance(
					DamageType.Type.MAGIC,
					SourceType.Type.PASSIVE,
					0.4 * character_base.total_statistics.attack_damage
					+ 0.2 * character_base.total_statistics.ability_power,
					true,
					true
				)

				Combat.apply_damage(splash_damage_info)

			character_base.calculate_statistics()
			
			_passive_area(area)

			break


func _passive_area(area: Area):
	await get_tree().create_timer(0.1).timeout
	
	area.queue_free()


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if passive_amount:
		bonus_statistics.attack_speed_multiplier += 1.25
		bonus_statistics.attack_range += 50


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(projectile: Projectile) -> void:
	var e2: bool = false

	for instance in projectile.damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_E:
			e2 = true
			break

	if !e2:
		return
	
	var target: CharacterBase = projectile.damage_info.victim

	var destination: Vector2 = (
		target.global_position
		- (target.global_position - character_base.global_position).normalized()
		* (
			target.character_collision_shape_radius
			+ character_base.character_collision_shape_radius
		)
	)

	var travel_time: float = (
		character_base.global_position.distance_to(destination)
		/ 1800.0
	)

	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, travel_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, travel_time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, travel_time)

	Combat.apply_forced_movement(
		character_base,
		destination,
		1800.0
	)
	
	var cast_id: String = projectile.damage_info.cast_id

	await get_tree().create_timer(travel_time).timeout

	if character_base.is_dead:
		return

	if target.is_dead:
		return

	var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)

	damage_info.add_damage_instance(
		DamageType.Type.MAGIC,
		SourceType.Type.SKILL_E,
		80.0
		+ 200.0 / 17.0 * character_base.level
		+ 0.8 * character_base.total_statistics.ability_power,
		false,
		false
	)

	Combat.apply_damage(damage_info)

	Combat.apply_crowd_control(target, CrowdControl.Type.AIRBORNE, 0.5)


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func cast_q(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_cooldown.remaining_duration > 0.0:
		return false

	if !Combat.spend_mana(character_base, 55.0):
		return false
	
	_q(cast_id)
	
	return true


func _q(cast_id: String) -> void:
	add_passive()

	q_cooldown.start(max(0.0, 10.0 - 4.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)

	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.4)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.4)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.4)
	
	var target_position: Vector2 = Ingame.current.get_global_mouse_position()

	await get_tree().create_timer(0.4).timeout

	var direction: Vector2 = target_position - character_base.global_position

	if direction.length() > 775.0:
		target_position = character_base.global_position + direction.normalized() * 775.0
	
	var area: Area = Area.create_rectangle(
		(character_base.global_position + target_position) / 2.0,
		(target_position - character_base.global_position).angle(),
		character_base.global_position.distance_to(target_position),
		120.0,
		true
	)

	Ingame.current.add_child(area)
	
	for target in area.get_targets():
		if !character_base.is_enemy_team(target):
			continue

		var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)

		damage_info.add_damage_instance(
			DamageType.Type.MAGIC,
			SourceType.Type.SKILL_Q,
			40.0
			+ 100.0 / 17.0 * character_base.level
			+ 0.45 * character_base.total_statistics.ability_power,
			false,
			false
		)

		Combat.apply_damage(damage_info)

		Combat.apply_crowd_control(
			target,
			CrowdControl.Type.SLOW,
			1.5,
			0.15 + 0.20 / 17.0 * character_base.level
		)

	await get_tree().create_timer(0.6).timeout

	var explosion_area: Area = Area.create_circle(
		target_position,
		180.0,
		true
	)

	Ingame.current.add_child(explosion_area)

	for target in explosion_area.get_targets():
		if !character_base.is_enemy_team(target):
			continue

		var damage_info: DamageInfo = DamageInfo.create(character_base, target, DamageInfo.generate_cast_id())

		damage_info.add_damage_instance(
			DamageType.Type.MAGIC,
			SourceType.Type.SKILL_Q,
			60.0
			+ 220.0 / 17.0 * character_base.level
			+ 0.8 * character_base.total_statistics.ability_power,
			false,
			false
		)

		Combat.apply_damage(damage_info)

	area.queue_free()

	_passive_area(explosion_area)


func cast_w(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false
	
	if !character_base.can_move():
		return false

	if w_cooldown.remaining_duration > 0.0:
		return false
	
	_w(cast_id)
	
	return true


func _w(cast_id: String) -> void:
	var target: CharacterBase = Ingame.current.get_target_at_mouse_position()

	if !target:
		return

	if target == character_base:
		return

	if !character_base.is_enemy_team(target):
		return

	if target.is_dead:
		return

	if !target.can_be_targeted():
		return

	if character_base.global_position.distance_to(target.global_position) > (
		400.0
		+ character_base.character_collision_shape_radius
		+ target.character_collision_shape_radius
	):
		return

	var mana_cost: float = (50.0 + 40.0 / 17.0 * character_base.level)

	if !Combat.spend_mana(character_base, mana_cost):
		return

	add_passive()

	w_cooldown.start(max(0.0, 12.0 - 6.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	var direction: Vector2 = (
		target.global_position
		- character_base.global_position
	).normalized()
	
	var destination: Vector2 = (
		target.global_position
		- direction * (
			target.character_collision_shape_radius
			+ character_base.character_collision_shape_radius
		)
	)
	
	var time: float = character_base.global_position.distance_to(destination) / 1024.0
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, time)

	Combat.apply_forced_movement(character_base, destination, 1024.0)

	await get_tree().create_timer(time).timeout

	if character_base.is_dead:
		return

	if target.is_dead:
		return

	if !target.can_be_targeted():
		return

	var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)

	damage_info.add_damage_instance(
		DamageType.Type.MAGIC,
		SourceType.Type.SKILL_W,
		75.0
		+ 140.0 / 17.0 * character_base.level
		+ 0.6 * character_base.total_statistics.ability_power,
		false,
		false
	)

	Combat.apply_damage(damage_info)

	var heal_multiplier: float = min(1.0,
		((character_base.total_statistics.health - character_base.current_health)
		/ character_base.total_statistics.health
		) * (1.0 / 0.6)
	)

	var heal_amount: float = (
		20.0
		+ 80.0 / 17.0 * character_base.level
		+ 0.3 * character_base.total_statistics.ability_power
		+ 0.05 * character_base.bonus_statistics.health
	) * (1.0 + heal_multiplier)

	Combat.apply_heal(character_base, heal_amount)


func cast_e(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false
	
	if e_active:
		_cast_e2(cast_id)
		return false
	
	if e_cooldown.remaining_duration > 0.0:
		return false
	
	if !Combat.spend_mana(character_base, 65.0):
		return false
	
	_e()
	
	return true


func _e() -> void:
	add_passive()

	e_active = true
	e_active_cooldown.remaining_duration = 3.5

	e_cooldown.start(max(0.0, 13.0 - 4.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)

	var target_position: Vector2 = Ingame.current.get_global_mouse_position()

	var direction: Vector2 = (target_position - character_base.global_position)

	if direction.length() > 400.0:
		direction = direction.normalized() * 400.0

	var destination: Vector2 = character_base.global_position + direction
	
	var time: float = character_base.global_position.distance_to(destination) / 1450.0
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, time)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, time)
	
	Combat.apply_forced_movement(character_base, destination, 1450.0)


func _cast_e2(cast_id: String) -> void:
	e_active = false
	e_active_cooldown.remaining_duration = 0.0

	add_passive()
	
	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.25)
	
	var mouse_position: Vector2 = Ingame.current.get_global_mouse_position()

	await get_tree().create_timer(0.25).timeout
	
	if character_base.is_dead:
		return

	var direction: Vector2 = (mouse_position - character_base.global_position).normalized()
	
	var damage_info: DamageInfo = DamageInfo.create(character_base, null, cast_id)
	
	damage_info.add_damage_instance(DamageType.Type.UNKNOWN, SourceType.Type.SKILL_E, 0.0, false, false)
	
	var projectile: Projectile = Ingame.current.spawn_projectile(
		damage_info,
		Projectile.Type.LINEAR,
		2500.0,
		60.0
	)

	projectile.direction = direction
	projectile.max_distance = 800.0
	projectile.pierce = false


func cast_r(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if r_active:
		_cast_r2()
		return false

	if r_cooldown.remaining_duration > 0:
		return false

	if !Combat.spend_mana(character_base, 100.0):
		return false
	
	_r()
	
	return true


func _r() -> void:
	r_active = true
	
	add_passive()

	r_active_cooldown.remaining_duration = 5.0

	r_cooldown.start(max(0.0, 120.0 - 40.0 / 17.0 * character_base.level), Cooldown.Type.ULTIMATE, character_base.total_statistics)


func _cast_r2() -> void:
	r_active = false
	r_active_cooldown.remaining_duration = 0.0

	var area: Area = Area.create_circle(character_base.global_position, 350.0, true)

	Ingame.current.add_child(area)

	for target in area.get_targets():
		if !character_base.is_enemy_team(target):
			continue

		var damage_info: DamageInfo = DamageInfo.create(character_base, target, DamageInfo.generate_cast_id())

		damage_info.add_damage_instance(
			DamageType.Type.MAGIC,
			SourceType.Type.SKILL_R,
			(200.0
				+ 200.0 / 17.0 * character_base.level
				+ 1.0 * character_base.total_statistics.ability_power
			) * (1.0 + 0.1 * passive_amount),
			false,
			false
		)

		Combat.apply_damage(damage_info)

		Combat.apply_crowd_control(target, CrowdControl.Type.SLOW, 0.2 + 0.05 * passive_amount, 0.4)
	
	passive_amount = 0
	
	add_passive()
	
	_passive_area(area)
