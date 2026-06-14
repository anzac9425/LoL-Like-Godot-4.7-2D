extends CharacterLogic


var passive_instances: Array[DariusPassive]

var q_cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if passive_instances:
		for i in range(passive_instances.size() - 1, -1, -1):
			var instance: DariusPassive = passive_instances[i]
			
			if instance.cooldown.remaining_duration > 0.0:
				instance.cooldown.remaining_duration -= delta
				
				if instance.cooldown.remaining_duration <= 0.0:
					passive_instances.remove_at(i)
					
					if instance.index == 5:
						var has_full: bool
						
						for instance_ in passive_instances:
							if instance_.index == 5:
								has_full = true
								break
						
						if !has_full:
							character_base.calculate_statistics()
						
						continue
			
			var passive_damage_info: DamageInfo = DamageInfo.create(character_base, instance.target)
			
			passive_damage_info.add_damage_instance(
				DamageType.Type.PHYSICAL,
				SourceType.Type.PASSIVE,
				(13.0 + character_base.level + 0.3 * character_base.bonus_statistics.attack_damage)
				* instance.index * delta,
				false,
				false
			)

			Combat.apply_damage(passive_damage_info)
	
	if q_cooldown.remaining_duration > 0:
		q_cooldown.remaining_duration -= delta


func apply_passive(target: CharacterBase):
	var passive_instance: DariusPassive

	for instance in passive_instances:
		if instance.target == target:
			passive_instance = instance
			break

	if !passive_instance:
		passive_instance = DariusPassive.new()
		passive_instance.target = target

		passive_instances.append(passive_instance)

	if passive_instance.index < 5:
		passive_instance.index += 1
		
		if passive_instance.index == 5:
			character_base.calculate_statistics() 

	passive_instance.cooldown.remaining_duration = 5.0


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	var add_passive_attack_damage: bool
	
	for instance in passive_instances:
		if instance.index == 5:
			add_passive_attack_damage = true
			
	if add_passive_attack_damage:
		bonus_statistics.attack_damage += 30.0 + 250.0 / 17.0 * character_base.level


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.source_type in [
			SourceType.Type.AUTO_ATTACK,
			SourceType.Type.SKILL_R
		]:
			apply_passive(damage_info.victim)
			break
		


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

	q_cooldown.remaining_duration = 9.0 - (4.0 / 17.0 * character_base.level)

	var outer_area: Area = Area.create_circle(
		character_base.global_position,
		425.0,
		true,
		character_base
	)

	var inner_area: Area = Area.create_circle(
		character_base.global_position,
		270.0,
		true,
		character_base
	)

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

	for target in targets:
		if !character_base.is_enemy_team(target):
			continue
		
		var is_inner: bool
		var damage: float = base_damage
		
		if character_base.global_position.distance_to(target.global_position) + target.character_collision_shape_radius < 270:
			damage *= 0.35
			is_inner = true

		var damage_info: DamageInfo = DamageInfo.create(character_base, target)

		damage_info.add_damage_instance(
			DamageType.Type.PHYSICAL,
			SourceType.Type.SKILL_Q,
			damage,
			false,
			false
		)

		Combat.apply_damage(damage_info)
		
		if !is_inner:
			Combat.apply_heal(character_base, 0.17 * (character_base.total_statistics.health - character_base.current_health))
			apply_passive(damage_info.victim)
		
		outer_area.queue_free()
		inner_area.queue_free()


func cast_w() -> void:
	pass


func cast_e() -> void:
	pass


func cast_r() -> void:
	pass
