extends CharacterLogic


var stack: int


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.ability_power += 5.0 * stack
	
	if stack >= 10:
		bonus_statistics.move_speed_multiplier += 0.1


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.victim.is_dead:
		var old: int = stack
		stack = min(25, stack + 4)
		
		if old != stack:
			character_base.calculate_statistics()
		


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
