extends CharacterLogic


var areas: Array[Area]

var passives: Array[Stack]

var w_hits: Dictionary
var w_duration: Cooldown = Cooldown.new()
var w_area: Area
var w_recast: bool
var w_arrived: bool

var r_area: Area
var r_duration: Cooldown = Cooldown.new()
var r_area_duration: Cooldown = Cooldown.new()
var r_recast: bool
var r_damage_info: DamageInfo
var r_amount: float


func _physics_process(delta: float) -> void:
	for i in range(passives.size() -1, -1, -1):
		var passive = passives[i]
		
		if passive.cooldown.remaining_duration > 0:
			passive.cooldown.remaining_duration -= delta
			
			if passive.cooldown.remaining_duration <= 0:
				passives.remove_at(i)
	
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta
	
	if w_cooldown.remaining_duration > 0:
		w_cooldown.remaining_duration -= delta
	
	if w_duration.remaining_duration > 0:
		w_duration.remaining_duration -= delta
		
		if w_duration.remaining_duration <= 0:
			areas.erase(w_area)
			
			w_area.queue_free()
			
			w_area = null
			w_recast = false
			w_arrived = false
	
	if e_cooldown.remaining_duration > 0:
		e_cooldown.remaining_duration -= delta
	
	if r_cooldown.remaining_duration > 0:
		r_cooldown.remaining_duration -= delta
	
	if r_duration.remaining_duration > 0:
		r_duration.remaining_duration -= delta
		
		if r_duration.remaining_duration <= 0:
			character_base.is_ghost = false
			
			r_damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_R, r_amount + character_base.total_statistics.attack_damage, false, false)
			
			Combat.apply_damage(r_damage_info)
			
			r_damage_info = null
			r_amount = 0
	
	if r_area_duration.remaining_duration > 0:
		r_area_duration.remaining_duration -= delta
		
		if r_area_duration.remaining_duration <= 0:
			areas.erase(r_area)
			
			r_area.queue_free()
			
			r_area = null


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(damage_info: DamageInfo) -> void:
	var passive_stack: Stack

	for passive in passives:
		if passive.target == damage_info.victim:
			passive_stack = passive
			
			break

	if !passive_stack:
		
		passive_stack = Stack.new()
		
		passive_stack.target = damage_info.victim
		
		passives.append(passive_stack)
	
	if passive_stack.target.current_health / passive_stack.target.total_statistics.health >= 0.5:
		return
	
	if passive_stack.cooldown.remaining_duration <= 0:
		passive_stack.cooldown.remaining_duration = 10.0

		damage_info.add_damage_instance(
			DamageType.Type.MAGIC,
			SourceType.Type.PASSIVE,
			(0.05 + 0.05 / 17.0 * character_base.level)
			* damage_info.victim.total_statistics.health,
			false,
			false
		)


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker == character_base:
		if r_damage_info:
			for instance in damage_info.damage_instances:
				r_amount += instance.amount * (0.25 + 0.3 / 17.0 * character_base.level) 


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.cast_id not in w_hits:
		w_hits[damage_info.cast_id] = {}

	var hits: Dictionary = w_hits[damage_info.cast_id]

	hits[damage_info.victim] = hits.get(damage_info.victim, 0) + 1

	if hits[damage_info.victim] > 1:
		Combat.apply_mana_restore(character_base, 30.0 + 20.0 / 17.0 * character_base.level)


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(projectile: Projectile) -> void:
	for instance in projectile.damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_Q:
			if projectile.hit_targets.size() > 1:
				instance.amount *= 0.6


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func cast_q(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if q_cooldown.remaining_duration > 0.0:
		return false

	if !Combat.spend_mana(character_base, max(0.0, 75.0 - 20.0 / 17.0 * character_base.level)):
		return false
	
	_q(cast_id)
	
	return true


func _q(cast_id: String) -> void:
	w_hits.erase(cast_id)
	
	q_cooldown.start(6.0, Cooldown.Type.SKILL, character_base.total_statistics)

	Combat.apply_status(character_base, Status.Type.CANNOT_MOVE, 0.25)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.25)
	
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.25)
	
	var mouse_pos: Vector2 = Ingame.current.get_global_mouse_position()

	await get_tree().create_timer(0.25).timeout

	if character_base.is_dead:
		return
	
	var direction: Vector2 = (mouse_pos - character_base.global_position).normalized()

	_q2(character_base.global_position, direction, cast_id)

	for area in areas:
		direction = (mouse_pos - area.global_position).normalized()
		
		_q2(area.global_position, direction, cast_id)


func _q2(position: Vector2, direction: Vector2, cast_id: String):
	var damage_info: DamageInfo = DamageInfo.create(character_base, null, cast_id)

	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.SKILL_Q,
		(80.0 + 160.0 / 17.0 * character_base.level)
		+ character_base.bonus_statistics.attack_damage,
		true,
		true
	)
	
	Ingame.current.spawn_projectile(damage_info.duplicate(), Projectile.Type.LINEAR, 1700.0, 50.0, position, direction, 925.0, true)


func cast_w(_cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if w_area:
		if !w_arrived:
			return false

		if !w_recast:
			_w2()
			return true

	if w_cooldown.remaining_duration > 0:
		return false

	if !Combat.spend_mana(character_base, max(0.0, 40.0 - 20.0 / 17.0 * character_base.level)):
		return false

	_w()
	return true


func _w() -> void:
	if is_instance_valid(w_area):
		areas.erase(w_area)
		w_area.queue_free()
		
		w_area = null
		w_duration.remaining_duration = 0
	
	w_recast = false
	w_arrived = false
	
	w_cooldown.start(max(0.0, 20.0 - 4.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	var area: Area = Area.create_circle(character_base.global_position, character_base.total_statistics.radius, true)
	
	areas.append(area)
	
	w_area = area
	
	Ingame.current.spawn_area(area)
	
	var target_position: Vector2 = Ingame.current.get_global_mouse_position()
	
	var direction: Vector2 = (target_position - character_base.global_position).limit_length(650.0)
	
	target_position = character_base.global_position + direction
	
	while area.global_position != target_position:
		var step: float = 2500.0 * get_physics_process_delta_time()
		
		if area.global_position.distance_to(target_position) <= step:
			area.global_position = target_position
			break

		area.global_position += (target_position - area.global_position).normalized() * step

		await get_tree().physics_frame
		
		if !is_instance_valid(area):
			return
	
	w_duration.remaining_duration = 5.25
	w_arrived = true


func _w2() -> void:
	w_recast = true
	
	var pos: Vector2 = character_base.global_position
	
	character_base.global_position = w_area.global_position
	character_base.is_moving = false
	character_base.forced_movement = null
	
	w_area.global_position = pos


func cast_e(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false

	if e_cooldown.remaining_duration > 0.0:
		return false

	if !Combat.spend_mana(character_base, 40.0):
		return false
	
	_e(cast_id)
	
	return true


func _e(cast_id: String) -> void:
	w_hits.erase(cast_id)
	
	e_cooldown.start(max(0.0, 5.0 - 2.0 / 17.0 * character_base.level), Cooldown.Type.SKILL, character_base.total_statistics)
	
	var e_areas: Array[Area]
	var e_targets: Array[CharacterBase]
	
	var area: Area = Area.create_circle(character_base.global_position, 315.0, true)
	
	e_areas.append(area)
	
	for shadow in areas:
		e_areas.append(Area.create_circle(shadow.global_position, 290.0, true))
	
	for area_ in e_areas:
		Ingame.current.spawn_area(area_)
		
		for target in area_.get_targets():
			if target == character_base:
				continue
			
			if target not in e_targets:
				if area_ == area:
					w_cooldown.remaining_duration -= 3.0
				
				e_targets.append(target)
				
				var damage_info: DamageInfo = DamageInfo.create(character_base, target, cast_id)
				
				damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.SKILL_E, 70.0 + 90.0 / 17.0 * character_base.level + 0.7 * character_base.bonus_statistics.attack_damage, false, false)
				
				Combat.apply_damage(damage_info)
				Combat.apply_crowd_control(target, CrowdControl.Type.SLOW, 1.5, 0.2 + 0.2 / 17.0 * character_base.level)
			
			else:
				Combat.apply_crowd_control(target, CrowdControl.Type.SLOW, 1.5, 1.5 * (0.2 + 0.2 / 17.0 * character_base.level))
		
		_e2(area_)


func _e2(area: Area) -> void:
	await get_tree().create_timer(0.1).timeout
	
	area.queue_free()


func cast_r(cast_id: String) -> bool:
	if !character_base.can_cast():
		return false
	
	if !r_recast:
		if r_duration.remaining_duration > 0:
			_r2()
			
			return true

	if r_cooldown.remaining_duration > 0.0:
		return false
	
	_r(cast_id)
	
	return true


func _r(cast_id) -> void:
	if is_instance_valid(r_area):
		areas.erase(r_area)
		r_area.queue_free()
		r_area = null
	
	r_duration.remaining_duration = 0
	r_area_duration.remaining_duration = 0

	r_damage_info = null
	r_amount = 0
	r_recast = false
	
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
		
	if character_base.global_position.distance_to(target.global_position) > 625.0 + character_base.character_collision_shape_radius + target.character_collision_shape_radius:
		return
	
	r_cooldown.start(max(0.0, 120.0 - 40.0 / 17.0 * character_base.level), Cooldown.Type.ULTIMATE, character_base.total_statistics)
	
	var area: Area = Area.create_circle(character_base.global_position, character_base.total_statistics.radius, true)
	
	areas.append(area)
	
	r_area = area
	
	Ingame.current.spawn_area(area)
	
	Combat.apply_status(character_base, Status.Type.UNTARGETABLE, 0.95)
	Combat.apply_status(character_base, Status.Type.CANNOT_AUTO_ATTACK, 0.95)
	Combat.apply_status(character_base, Status.Type.CANNOT_CAST, 0.95)
	Combat.apply_status(character_base, Status.Type.CANNOT_SPELL, 0.95)
	
	var old_collision_layer = character_base.collision_layer
	
	character_base.collision_layer = 0
	character_base.visible = false
	
	await get_tree().create_timer(0.6).timeout
	
	if character_base.is_dead or target.is_dead:
		character_base.collision_layer = old_collision_layer
		character_base.visible = true
		
		areas.erase(r_area)
		r_area.queue_free()
		r_area = null
		
		return
	
	character_base.visible = true
	
	var destination: Vector2 = target.global_position + (target.global_position - character_base.global_position).normalized() * 125.0

	Combat.apply_forced_movement(character_base, destination, character_base.global_position.distance_to(destination) / 0.35)
	
	await get_tree().create_timer(0.35).timeout
	
	character_base.collision_layer = old_collision_layer
	character_base.is_ghost = true
	
	r_damage_info = DamageInfo.create(character_base, target, cast_id)
	
	r_duration.remaining_duration = 3.0
	r_area_duration.remaining_duration = 9.0


func _r2() -> void:
	r_recast = true
	
	var pos: Vector2 = character_base.global_position
	
	character_base.global_position = r_area.global_position
	character_base.is_moving = false
	character_base.forced_movement = null
	
	r_area.global_position = pos
