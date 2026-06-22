class_name Combat


static func apply_damage(damage_info: DamageInfo) -> void:
	if damage_info.attacker.is_same_team(damage_info.victim):
		return
		
	if !damage_info.victim.can_take_damage():
		return
	
	damage_info.attacker.build_damage_info(damage_info)
	damage_info.victim.build_damage_info(damage_info)
	
	if damage_info.on_hit:
		damage_info.attacker.on_hit(damage_info)
	
		for i in range(damage_info.on_hit_count - 1):
			damage_info.attacker.on_hit(damage_info)
	
	var damage_amount: Dictionary
	
	var is_critical: bool = randf() < damage_info.attacker.total_statistics.critical_chance
	
	if is_critical:
		damage_info.was_crit = true
	
	for type in DamageType.Type.values():
		damage_amount[type] = 0.0
	
	for instance in damage_info.damage_instances:
		var amount: float = instance.amount
		
		if instance.allow_critical and is_critical:
			amount *= damage_info.attacker.total_statistics.critical_damage_multiplier
		
		match instance.damage_type:
			DamageType.Type.PHYSICAL:
				amount *= 100 / (100 + max(0.0, max(0.0, (1 - damage_info.attacker.total_statistics.armor_penetration_multiplier)) * damage_info.victim.total_statistics.armor - damage_info.attacker.total_statistics.armor_penetration_flat))
			
			DamageType.Type.MAGIC:
				amount *= 100 / (100 + max(0.0, max(0.0, (1 - damage_info.attacker.total_statistics.magic_penetration_multiplier)) * damage_info.victim.total_statistics.magic_resistance - damage_info.attacker.total_statistics.magic_penetration_flat))
		
		if instance.allow_lifesteal:
			apply_heal(damage_info.attacker, amount * damage_info.attacker.total_statistics.lifesteal)
		
		apply_heal(damage_info.attacker, amount * damage_info.attacker.total_statistics.omnivamp)
		
		damage_amount[instance.damage_type] += amount
		
	for type in damage_amount:
		for i in range(damage_info.victim.barriers.size() - 1, -1, -1):
			if damage_amount[type] <= 0.0:
				break

			var barrier: Barrier = damage_info.victim.barriers[i]

			match barrier.type:
				Barrier.Type.NORMAL:
					pass

				Barrier.Type.PHYSICAL:
					if type != DamageType.Type.PHYSICAL:
						continue

				Barrier.Type.MAGIC:
					if type != DamageType.Type.MAGIC:
						continue

			var absorbed: float = min(barrier.amount, damage_amount[type])

			barrier.amount -= absorbed
			damage_amount[type] -= absorbed

			if barrier.amount <= 0.0:
				damage_info.victim.barriers.remove_at(i)

		damage_info.victim.current_health = max(0.0, damage_info.victim.current_health - damage_amount[type])
	
	if damage_info.victim.current_health <= 0:
		if !damage_info.victim.on_lethal_damage(damage_info):
			damage_info.victim.die()
	
	var result_info: DamageInfo = damage_info.duplicate()
	
	damage_info.attacker.on_deal_damage(result_info)
	damage_info.victim.on_take_damage(result_info)
		
	damage_info.attacker.queue_redraw()
	damage_info.victim.queue_redraw()


static func apply_heal(target: CharacterBase, amount: float) -> Array[float]:
	if target.is_dead:
		return [0, 0]
	
	amount *= (1.0 + target.total_statistics.heal_shield_power_multiplier)
	
	if target.has_effect(Effect.Type.HEAL_REDUCTION):
		amount *= 1 - target.get_effect_amount(Effect.Type.HEAL_REDUCTION)
	
	var request_amount: float = amount
	
	amount = min(amount, target.total_statistics.health - target.current_health)
	
	target.current_health += amount
	
	target.queue_redraw()
	
	return [request_amount, amount]


static func apply_mana_restore(target: CharacterBase, amount: float) -> void:
	if target.is_dead:
		return
	
	target.current_mana += amount

	if target.current_mana > target.total_statistics.mana:
		target.current_mana = target.total_statistics.mana
	
	target.queue_redraw()


static func apply_barrier(target: CharacterBase, amount: float, duration: float, type: Barrier.Type = Barrier.Type.NORMAL) -> void:
	if target.is_dead:
		return
	
	var barrier: Barrier = Barrier.new()
	
	barrier.type = type
	barrier.amount = amount * (1.0 + target.total_statistics.heal_shield_power_multiplier)
	barrier.amount *= max(0.0, 1.0 - target.get_effect_amount(Effect.Type.BARRIER_REDUCTION))
	barrier.remaining_duration = duration

	target.barriers.push_back(barrier)
	
	target.queue_redraw()

static func apply_crowd_control(target: CharacterBase, type: CrowdControl.Type, duration: float, amount: float = 0.0):
	if target.is_dead:
		return
	
	if !target.can_be_crowd_controlled():
		return
	
	var crowd_control: CrowdControl = CrowdControl.new()
	
	crowd_control.type = type
	crowd_control.amount = amount
	crowd_control.remaining_duration = duration
	
	if type == CrowdControl.Type.SLOW:
		crowd_control.amount = clamp(amount, 0.0, 1.0)
	
	if type != CrowdControl.Type.AIRBORNE:
		crowd_control.remaining_duration *= max(0.0, (1.0 - target.total_statistics.tenacity))
	
	target.crowd_controls.append(crowd_control)
	
	if type == CrowdControl.Type.SLOW:
		target.calculate_statistics()


static func apply_status(target: CharacterBase, type: Status.Type, duration: float):
	if target.is_dead:
		return
	
	var status: Status = Status.new()
	
	status.type = type
	status.remaining_duration = duration
	
	target.statuses.append(status)


static func apply_forced_movement(
	target: CharacterBase,
	destination: Vector2,
	speed: float
) -> void:
	var movement: ForcedMovement = ForcedMovement.new()

	movement.destination = destination
	movement.speed = speed

	target.forced_movement = movement


static func spend_mana(target: CharacterBase, amount: float) -> bool:
	if target.current_mana < amount:
		return false

	target.current_mana -= amount
	target.queue_redraw()

	return true


static func apply_effect(target: CharacterBase, type: Effect.Type, duration: float, amount: float):
	if target.is_dead:
		return

	var effect: Effect = Effect.new()

	effect.type = type
	effect.remaining_duration = duration
	effect.amount = amount

	target.effects.append(effect)

	target.calculate_statistics()
