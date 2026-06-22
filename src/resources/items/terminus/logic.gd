extends CharacterLogic


var light_stack: Stack = Stack.new()
var dark_stack: Stack = Stack.new()
var last: bool


func _physics_process(delta: float) -> void:
	if light_stack.cooldown.remaining_duration > 0:
		light_stack.cooldown.remaining_duration -= delta
		
		if light_stack.cooldown.remaining_duration <= 0:
			light_stack.stack = 0.0
			
			character_base.calculate_statistics()
	
	if dark_stack.cooldown.remaining_duration > 0:
		dark_stack.cooldown.remaining_duration -= delta
		
		if dark_stack.cooldown.remaining_duration <= 0:
			dark_stack.stack = 0.0
			
			character_base.calculate_statistics()
		


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(damage_info: DamageInfo) -> void:
	damage_info.add_damage_instance(DamageType.Type.MAGIC, SourceType.Type.ITEM, 30.0, false, false)
	
	if !last:
		light_stack.stack = min(3.0, light_stack.stack + 1.0)
		light_stack.cooldown.remaining_duration = 5.0
		
		last = true
	
	else:
		dark_stack.stack = min(3.0, dark_stack.stack + 1.0)
		dark_stack.cooldown.remaining_duration = 5.0
		
		
		last = false
	
	
	character_base.calculate_statistics()


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.armor += light_stack.stack * (6.0 + 2.0 / 17.0 * character_base.level)
	bonus_statistics.magic_resistance += light_stack.stack * (6.0 + 2.0 / 17.0 * character_base.level)
	
	bonus_statistics.armor_penetration_multiplier += 0.1 * dark_stack.stack
	bonus_statistics.magic_penetration_multiplier += 0.1 * dark_stack.stack

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
