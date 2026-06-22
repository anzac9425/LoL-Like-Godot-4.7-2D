extends CharacterLogic


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
	
	if damage_info.is_dot:
		return
	
	var physical: bool
	
	for instance in damage_info.damage_instances:
		if instance.damage_type == DamageType.Type.PHYSICAL:
			physical = true
			
			break
	
	if !physical:
		return
	
	damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM,  min(0.12, 0.12 * (1.0 - character_base.current_health / character_base.total_statistics.health) / 0.7) * character_base.total_statistics.attack_damage, false, false)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.attack_damage += 0.025 * bonus_statistics.health


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
