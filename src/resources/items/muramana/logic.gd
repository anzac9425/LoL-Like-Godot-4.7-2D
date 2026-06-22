extends CharacterLogic


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(damage_info: DamageInfo) -> void:
	damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM, 0.012 * character_base.total_statistics.mana, false, false)


func build_damage_info(damage_info: DamageInfo) -> void:
	var active: bool
	
	if damage_info.is_dot:
		return
	
	for instance in damage_info.damage_instances:
		match instance.source_type:
			SourceType.Type.SKILL_Q:
				active = true
			
			SourceType.Type.SKILL_W:
				active = true
			
			SourceType.Type.SKILL_E:
				active = true
			
			SourceType.Type.SKILL_R:
				active = true
	
	if !active:
		return
	if character_base.character_data.ranged:
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM, 0.03 * character_base.total_statistics.mana, false, false)
	
	else:
		damage_info.add_damage_instance(DamageType.Type.PHYSICAL, SourceType.Type.ITEM, 0.04 * character_base.total_statistics.mana, false, false)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	bonus_statistics.attack_damage += 0.02 * raw_total_statistics.mana


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
