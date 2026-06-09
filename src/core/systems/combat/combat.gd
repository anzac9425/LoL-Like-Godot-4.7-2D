class_name Combat


static func calculate_damage(damage_info: DamageInfo) -> float:
	var damage: float
	
	for instance in damage_info.damage_instances:
		
