extends CharacterLogic


var passive_ready: bool
var passive_cooldown: Cooldown = Cooldown.new()

var q_index: int
var q_casting: bool
var q_rotation: float
var q_cooldown: Cooldown = Cooldown.new()
var q_recast: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_cooldown.remaining_duration > 0.0:
		passive_cooldown.remaining_duration -= delta

	if passive_cooldown.remaining_duration <= 0.0:
		passive_ready = true
		
	if q_cooldown.remaining_duration > 0.0:
		q_cooldown.remaining_duration -= delta

	if q_recast.remaining_duration > 0.0:
		q_recast.remaining_duration -= delta

		if q_recast.remaining_duration <= 0.0:
			q_index = 0
			q_cooldown.remaining_duration = 14.0


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker == character_base:
		if passive_ready:
			var has_auto_attack: bool

			for instance in damage_info.damage_instances:
				if instance.source_type == SourceType.Type.AUTO_ATTACK:
					has_auto_attack = true
					break
			
			if has_auto_attack:
				passive_ready = false
				passive_cooldown.remaining_duration = (22.0 - 10.0 / 17.0 * character_base.level)
				
				damage_info.add_damage_instance(
					DamageType.Type.MAGIC,
					SourceType.Type.PASSIVE,
					damage_info.victim.total_statistics.health * (0.04 + 0.06 / 17.0 * character_base.level),
					true,
					true
				)


func on_deal_damage(damage_info: DamageInfo) -> void:
	var reduce_cooldown: bool

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.PASSIVE:
			Combat.apply_heal(character_base, instance.amount)

		else:
			reduce_cooldown = true

	if reduce_cooldown:
		passive_cooldown.remaining_duration -= 2.0


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func cast_q() -> void:
	if !character_base.can_cast():
		return

	if q_casting:
		return

	if q_index == 0 and q_cooldown.remaining_duration > 0.0:
		return

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

	Combat.apply_status(
		character_base,
		Status.Type.CANNOT_MOVE,
		0.6
	)

	Combat.apply_status(
		character_base,
		Status.Type.CANNOT_AUTO_ATTACK,
		0.6
	)

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

		var damage_info: DamageInfo = DamageInfo.create(
			character_base,
			target
		)

		var damage: float = base_damage * damage_multiplier

		if target in sweet_targets:
			damage *= 1.7

			Combat.apply_crowd_control(
				target,
				CrowdControl.Type.AIRBORNE,
				0.25
			)
			
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
		q_cooldown.remaining_duration = 14.0
		q_casting = false
	else:
		q_index = next_index
		await get_tree().create_timer(0.4).timeout
		q_casting = false


func cast_w() -> void:
	pass


func cast_e() -> void:
	pass


func cast_r() -> void:
	pass
