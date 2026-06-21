extends CharacterLogic


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker == character_base:
		for instance in damage_info.damage_instances:
			instance.amount *= 1.0 + 0.15 * min(1.0, damage_info.victim.bonus_statistics.health / 1500.0)


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
