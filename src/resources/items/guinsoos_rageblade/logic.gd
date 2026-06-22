extends CharacterLogic


var stack: Stack = Stack.new()
var stack2: Stack = Stack.new()


func _physics_process(delta: float) -> void:
	if stack.cooldown.remaining_duration > 0:
		stack.cooldown.remaining_duration -= delta
		
		if stack.cooldown.remaining_duration <= 0:
			stack.stack = 0.0
			stack2.stack = 0.0
			
			character_base.calculate_statistics()
	
	if stack2.cooldown.remaining_duration > 0:
		stack2.cooldown.remaining_duration -= delta
		
		if stack2.cooldown.remaining_duration <= 0:
			stack2.stack = 0.0



func on_attack(damage_info: DamageInfo) -> void:
	stack.stack = min(4.0, stack.stack + 1.0)
	stack.cooldown.remaining_duration = 3.0
	
	if stack.stack >= 4.0:
		stack2.stack += 1.0
		stack2.cooldown.remaining_duration = 6.0
		
		if stack2.stack >= 3.0:
			stack2.stack = 0.0
			
			damage_info.on_hit_count += 1
	
	character_base.calculate_statistics()


func on_hit(damage_info: DamageInfo) -> void:
	damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.ITEM, 30.0, false, false)


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.attack_speed_multiplier += 0.08 * stack.stack


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


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func on_cast(_source_type: SourceType.Type) -> void:
	pass
