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
	var amount: float
	
	if character_base.character_data.ranged:
		amount = 0.35
	
	else:
		amount = 0.5
	
	if !damage_info.victim.has_effect(Effect.Type.BARRIER_REDUCTION):
		for barrier in damage_info.victim.barriers:
			barrier.amount *= 1.0 - amount
	
	Combat.apply_effect(damage_info.victim, Effect.Type.BARRIER_REDUCTION, 3.0, amount)


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
