extends CharacterLogic


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
	for instance in damage_info.damage_instances:
		if instance.damage_type == DamageType.Type.MAGIC:
			Combat.apply_effect(damage_info.victim, Effect.Type.GRIEVOUS_WOUNDS, 3.0, 0.4)
			
			return


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
