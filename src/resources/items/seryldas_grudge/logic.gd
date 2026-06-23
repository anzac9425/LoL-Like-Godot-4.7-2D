extends CharacterLogic


func on_attack(_damage_info: DamageInfo) -> void:
	pass


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
	if damage_info.is_dot:
		return
	
	if damage_info.victim.current_health / damage_info.victim.total_statistics.health > 0.5:
		return
	
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
	
	Combat.apply_crowd_control(damage_info.victim, CrowdControl.Type.SLOW, 1.0, 0.3)


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
