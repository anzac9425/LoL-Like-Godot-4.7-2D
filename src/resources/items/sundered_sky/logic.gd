extends CharacterLogic


var instances: Array[Stack]
var overheal: float
var duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	for i in range(instances.size() - 1, -1, -1):
		var instance: Stack = instances[i]

		instance.cooldown.remaining_duration -= delta

		if instance.cooldown.remaining_duration <= 0.0:
			instances.remove_at(i)
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			overheal = 0
			
			character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return

	var auto_attack: bool

	for damage_instance in damage_info.damage_instances:
		if damage_instance.source_type == SourceType.Type.AUTO_ATTACK:
			auto_attack = true
			break

	if !auto_attack:
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

	if stack_instance.cooldown.remaining_duration > 0.0:
		return

	stack_instance.cooldown.remaining_duration = 10.0

	for damage_instance in damage_info.damage_instances:
		if damage_instance.source_type == SourceType.Type.AUTO_ATTACK:
			damage_instance.amount *= (0.8 * character_base.total_statistics.critical_damage_multiplier)

	var heal_amount: float = 0.06 * (character_base.total_statistics.health - character_base.current_health)

	if character_base.character_data.ranged:
		heal_amount += character_base.base_statistics.attack_damage * 0.5
	
	else:
		heal_amount += character_base.base_statistics.attack_damage
	
	var applied_heal: Array[float] = Combat.apply_heal(character_base, heal_amount)
	
	overheal += applied_heal[0] - applied_heal[1]

	if overheal:
		duration.remaining_duration = 8.0
		character_base.calculate_statistics()


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.health += overheal


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


func on_cast(_source_type: SourceType.Type):
	pass
