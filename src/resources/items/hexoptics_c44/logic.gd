extends CharacterLogic


var duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			character_base.calculate_statistics()


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.AUTO_ATTACK:
			instance.amount *= 1.0 + 0.0002 * damage_info.attacker.global_position.distance_to(damage_info.victim.global_position)


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if duration.remaining_duration > 0:
		bonus_statistics.attack_range += 100.0


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.victim.is_dead:
		duration.remaining_duration = 8.0
		
		character_base.calculate_statistics()


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
