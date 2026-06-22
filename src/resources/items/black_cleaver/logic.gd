extends CharacterLogic


var instances: Array[Stack]
var duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if instances:
		for i in range(instances.size() - 1, -1, -1):
			var instance: Stack = instances[i]

			instance.cooldown.remaining_duration -= delta

			if instance.cooldown.remaining_duration <= 0.0:
				instances.remove_at(i)
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if duration.remaining_duration > 0:
		bonus_statistics.move_speed += 20.0


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.is_dot:
		return
	
	var has_physical_damage: bool

	for instance in damage_info.damage_instances:
		if instance.damage_type == DamageType.Type.PHYSICAL:
			has_physical_damage = true
			break

	if !has_physical_damage:
		return

	var stack_instance: Stack

	for value in instances:
		if value.target == damage_info.victim:
			stack_instance = value
			break

	if !stack_instance:
		stack_instance = Stack.new()
		stack_instance.target = damage_info.victim

		instances.append(stack_instance)

	stack_instance.stack = min(5, stack_instance.stack + 1)
	stack_instance.cooldown.remaining_duration = 6.0

	Combat.apply_effect(damage_info.victim, Effect.Type.ARMOR_REDUCTION, 6.0, stack_instance.stack * 6)
	
	if duration.remaining_duration <= 0.0:
		character_base.calculate_statistics()
		
	duration.remaining_duration = 2.0


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
