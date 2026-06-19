extends CharacterLogic


var stacks: Array[Stack]
var cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0.0:
		cooldown.remaining_duration -= delta

	for i in range(stacks.size() - 1, -1, -1):
		var stack: Stack = stacks[i]

		if stack.cooldown.remaining_duration > 0.0:
			stack.cooldown.remaining_duration -= delta

			if stack.target.is_dead:
				_explode(stack)
				stacks.remove_at(i)
				continue

			if stack.cooldown.remaining_duration <= 0.0:
				var damage_info: DamageInfo = DamageInfo.create(character_base, stack.target, DamageInfo.generate_cast_id())

				damage_info.add_damage_instance(
					DamageType.Type.MAGIC,
					SourceType.Type.ITEM,
					125.0 + character_base.total_statistics.ability_power * 0.1,
					false,
					false
				)

				Combat.apply_damage(damage_info)
				stacks.remove_at(i)


func _explode(stack: Stack) -> void:
	var area: Area = Area.create_circle(stack.target.global_position, 600.0, true)

	Ingame.current.spawn_area(area)

	var targets: Array[CharacterBase] = area.get_targets()

	for target in targets:
		if character_base.is_same_team(target):
			continue
		
		var damage_info: DamageInfo = DamageInfo.create(character_base, target, DamageInfo.generate_cast_id())

		damage_info.add_damage_instance(
			DamageType.Type.MAGIC,
			SourceType.Type.ITEM,
			125.0 + character_base.total_statistics.ability_power * 0.1,
			false,
			false
		)

		Combat.apply_damage(damage_info)

	await get_tree().create_timer(0.1).timeout

	area.queue_free()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if cooldown.remaining_duration > 0.0:
		return

	var amount: float = 0.0

	for instance in damage_info.damage_instances:
		amount += instance.amount

	var stack: Stack

	for value in stacks:
		if value.target == damage_info.victim:
			stack = value
			break

	if !stack:
		stack = Stack.new()
		stack.target = damage_info.victim

		stacks.append(stack)

	stack.stack += amount

	if stack.cooldown.remaining_duration <= 0.0:
		if stack.stack >= stack.target.total_statistics.health * 0.25:
			stack.cooldown.remaining_duration = 2.0

			cooldown.start(30.0, Cooldown.Type.ITEM, character_base.total_statistics)
	
	var stack_: Stack = stack
	var amount_: float = amount
	
	await get_tree().create_timer(2.5).timeout

	if !is_inside_tree():
		return

	if !stacks.has(stack_):
		return

	stack.stack = max(0.0, stack_.stack - amount_)

	if stack_.stack <= 0.0 && stack_.cooldown.remaining_duration <= 0.0:
		stacks.erase(stack_)


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
