extends CharacterLogic


var stack: Stack = Stack.new()


func _physics_process(delta: float) -> void:
	if stack.cooldown.remaining_duration > 0:
		stack.cooldown.remaining_duration -= delta
		
		if stack.cooldown.remaining_duration <= 0:
			stack.stack = 0


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return

	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.PASSIVE or instance.source_type == SourceType.Type.SKILL_Q or instance.source_type == SourceType.Type.SKILL_W or instance.source_type == SourceType.Type.SKILL_E or  instance.source_type == SourceType.Type.SKILL_R:
			instance.amount *= (1.0 + 0.03 * stack.stack)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	var skill: bool

	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.SKILL_Q:
				skill = true
			SourceType.Type.SKILL_W:
				skill = true
			SourceType.Type.SKILL_E:
				skill = true
			SourceType.Type.SKILL_R:
				skill = true

	if !skill:
		return
	
	stack.cooldown.remaining_duration = 6.0
	stack.stack = min(4.0, stack.stack + 1.0)


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
