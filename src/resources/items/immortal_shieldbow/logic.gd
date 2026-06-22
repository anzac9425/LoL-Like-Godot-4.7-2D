extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta


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


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	if cooldown.remaining_duration <= 0:
		if character_base.current_health / character_base.total_statistics.health < 0.3:
			cooldown.start(90.0, Cooldown.Type.ITEM, character_base.total_statistics)
			
			if character_base.character_data.ranged:
				Combat.apply_barrier(character_base, 320.0 + 240.0 / 17.0 * character_base.level, 3.0)
			
			else:
				Combat.apply_barrier(character_base, 400.0 + 300.0 / 17.0 * character_base.level, 3.0)


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func on_cast(_source_type: SourceType.Type) -> void:
	pass
