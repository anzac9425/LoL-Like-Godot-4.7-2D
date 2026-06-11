class_name Combat


static func apply_damage(damage_info: DamageInfo) -> void:
	if !damage_info.victim.can_take_damage():
		return
	
	var damage_amount: Dictionary
	
	var is_critical: bool = randf() < damage_info.attacker.total_statistics.critical_chance
	
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
		var amount: float = damage_amount[type]

		for i in range(damage_info.victim.barriers.size() - 1, -1, -1):
			if amount <= 0.0:
				break

			var barrier: Barrier = damage_info.victim.barriers[i]

			var absorbed: float = min(barrier.amount, amount)

			barrier.amount -= absorbed
			amount -= absorbed

			if barrier.amount <= 0.0:
				damage_info.victim.barriers.remove_at(i)
			
		damage_info.victim.current_health = max(0.0, damage_info.victim.current_health - amount)
	
	damage_info.attacker.queue_redraw()
	damage_info.victim.queue_redraw()
	
	if damage_info.victim.current_health <= 0:
		damage_info.victim.die()
	

static func apply_heal(target: CharacterBase, amount: float) -> void:
	if target.is_dead:
		return
	amount *= (1.0 + target.total_statistics.heal_shield_power_multiplier)
	
	target.current_health += amount

	if target.current_health > target.total_statistics.health:
		target.current_health = target.total_statistics.health
	
	target.queue_redraw()


static func apply_barrier(target: CharacterBase, amount: float, duration: float) -> void:
	if target.is_dead:
		return
	
	var barrier: Barrier = Barrier.new()

	barrier.amount = amount * (1.0 + target.total_statistics.heal_shield_power_multiplier)
	barrier.remaining_duration = duration

	target.barriers.push_back(barrier)
	
	target.queue_redraw()

static func apply_crowd_control(target: CharacterBase, type: CrowdControl.Type, amount: float, duration: float):
	if target.is_dead:
		return
	
	if !target.can_be_crowd_controlled():
		return
	
	var crowd_control: CrowdControl = CrowdControl.new()
	
	crowd_control.type = type
	crowd_control.amount = amount
	crowd_control.remaining_duration = duration * max(0.0, (1.0 - target.total_statistics.tenacity))
	
	target.crowd_controls.append(crowd_control)


static func apply_status(target: CharacterBase, type: Status.Type, duration: float):
	if target.is_dead:
		return
	
	var status: Status = Status.new()
	
	status.type = type
	status.remaining_duration = duration
	
	target.statuses.append(status)
