extends CharacterLogic


var instances: Array[Stack]

var duration: Cooldown = Cooldown.new()
var stack: float


func _physics_process(delta: float) -> void:
	if instances:
		for i in range(instances.size() - 1, -1, -1):
			var instance: Stack = instances[i]
			
			instance.cooldown.remaining_duration -= delta
			
			if instance.cooldown.remaining_duration <= 0.0:
				instances.remove_at(i)
				continue
			
			var damage_info: DamageInfo = DamageInfo.create(character_base, instance.target, instance.cast_ids[0], true)
			
			damage_info.add_damage_instance(
				DamageType.Type.MAGIC,
				SourceType.Type.ITEM,
				0.02 * instance.target.total_statistics.health * delta,
				false,
				false
			)
			
			Combat.apply_damage(damage_info)
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		stack = min(3.0, stack + delta)
		
		if duration.remaining_duration <= 0:
			stack = 0.0


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
	
	for instance in damage_info.damage_instances:
		instance.amount *= 1 + stack * 2 / 100


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	duration.remaining_duration = 5.0
	
	var has_ability_damage: bool

	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.SKILL_Q:
				has_ability_damage = true
			SourceType.Type.SKILL_W:
				has_ability_damage = true
			SourceType.Type.SKILL_E:
				has_ability_damage = true
			SourceType.Type.SKILL_R:
				has_ability_damage = true

	if !has_ability_damage:
		return
	
	var stack_instance: Stack

	for value in instances:
		if value.target == damage_info.victim:
			stack_instance = value
			break
	
	if !stack_instance:
		stack_instance = Stack.new()
		stack_instance.target = damage_info.victim
		stack_instance.cast_ids.append(DamageInfo.generate_cast_id())

		instances.append(stack_instance)
	
	stack_instance.cooldown.remaining_duration = 3.0


func on_take_damage(_damage_info: DamageInfo) -> void:
	duration.remaining_duration = 5.0


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
