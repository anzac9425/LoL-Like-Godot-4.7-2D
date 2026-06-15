extends CharacterLogic


var passive_amount: int
var passive_cooldown: Cooldown = Cooldown.new()

var q_cooldown: Cooldown = Cooldown.new()

var w_cooldown: Cooldown = Cooldown.new()

var e_cooldown: Cooldown = Cooldown.new()

var r_cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_cooldown.remaining_duration > 0:
		passive_cooldown.remaining_duration -= delta
		
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta
	
	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta
	
	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta
	
	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta
	


func add_passive() -> void:
	passive_amount = min(passive_amount + 1, 3)

	character_base.calculate_statistics()


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
	
	if !passive_amount:
		return
	
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			passive_amount -= 1
			
			damage_info.add_damage_instance(
				DamageType.Type.MAGIC,
				SourceType.Type.PASSIVE,
				1.3 * character_base.total_statistics.attack_damage
				+ 0.3 * character_base.total_statistics.ability_power,
				true,
				true
			)
			
			var area: Area = Area.create_circle(damage_info.victim.global_position, 300.0, true)
			
			Ingame.current.add_child(area)
			
			for target in area.get_targets():
				if target == damage_info.victim:
					continue
				
				if !character_base.is_enemy_team(target):
					continue
				
				var splash_damage_info: DamageInfo = DamageInfo.create(character_base, target)

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


func cast_q() -> void:
	if !character_base.can_cast():
		return

	if q_cooldown.remaining_duration > 0.0:
		return

	if !Combat.spend_mana(character_base, 55.0):
		return

	add_passive()

	q_cooldown.remaining_duration = max(0.0, 10.0 - 4.0 / 17.0 * character_base.level)

	Combat.apply_status(
		character_base,
		Status.Type.CANNOT_MOVE,
		0.4
	)
	
	Combat.apply_status(
		character_base,
		Status.Type.CANNOT_AUTO_ATTACK,
		0.4
	)
	
	Combat.apply_status(
		character_base,
		Status.Type.CANNOT_CAST,
		0.4
	)
	
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

		var damage_info: DamageInfo = DamageInfo.create(character_base, target)

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

		var damage_info: DamageInfo = DamageInfo.create(character_base, target)

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


func cast_w() -> void:
	pass


func cast_e() -> void:
	pass


func cast_r() -> void:
	pass
