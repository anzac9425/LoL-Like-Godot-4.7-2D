extends CharacterLogic


var stacks: Array[Stack]
var cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0.0:
		cooldown.remaining_duration -= delta

	for i in range(stacks.size() - 1, -1, -1):
		var stack: Stack = stacks[i]

		stack.cooldown.remaining_duration -= delta

		if stack.cooldown.remaining_duration <= 0.0:
			stacks.remove_at(i)


func get_stack_(target: CharacterBase) -> Stack:
	for stack in stacks:
		if stack.target == target:
			return stack

	return null


func on_hit(damage_info: DamageInfo) -> void:
	var damage: float
	
	if damage_info.attacker.character_data.ranged:
		damage = damage_info.victim.current_health * 0.06
	
	else:
		damage = damage_info.victim.current_health * 0.09

	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.ITEM,
		damage,
		false,
		true
	)
	
	if cooldown.remaining_duration > 0.0:
		return

	var target: CharacterBase = damage_info.victim

	var stack: Stack = get_stack_(target)

	if !stack:
		stack = Stack.new()
		stack.target = target
		stacks.append(stack)

	stack.stack += 1
	stack.cooldown.remaining_duration = 6.0

	if stack.stack >= 3:
		stacks.erase(stack)

		Combat.apply_crowd_control(
			target,
			CrowdControl.Type.SLOW,
			1.0,
			0.30
		)

		cooldown.start(15.0, Cooldown.Type.ITEM, character_base.total_statistics)


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


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
