extends CharacterLogic


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.allow_lifesteal:
			instance.allow_lifesteal = false
			
			var heal: Array[float] = Combat.apply_heal(character_base, instance.amount * character_base.total_statistics.lifesteal)
			
			if heal[0] != heal[1]:
				var amount: float = 0.0
				
				for barrier in character_base.barriers:
					amount += barrier.amount
				
				if amount < 165.0 + 150.0 / 17.0 * character_base.level:
					Combat.apply_barrier(character_base, min(heal[0] - heal[1], max(0.0, 165.0 + 150.0 / 17.0 * character_base.level - amount)), INF)


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


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
