extends CharacterLogic


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	bonus_statistics.ability_power += 0.3 * raw_total_statistics.ability_power


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
