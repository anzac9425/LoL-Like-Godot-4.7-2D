extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()
var duration: Cooldown= Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			character_base.calculate_statistics()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	bonus_statistics.attack_damage += 0.45 * base_statistics.attack_damage


func modify_total_statistics(_base_statistics: Statistics, bonus_statistics: Statistics, raw_total_statistics: Statistics) -> void:
	if duration.remaining_duration > 0:
		bonus_statistics.radius += 0.1 * raw_total_statistics.radius


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	if cooldown.remaining_duration > 0:
		return
	
	if character_base.current_health / character_base.total_statistics.health < 0.3:
		Combat.apply_barrier(character_base, 0.6 * character_base.bonus_statistics.health, 3.0)
		
		cooldown.remaining_duration = 90.0
		
		duration.remaining_duration = 8.0
		
		character_base.calculate_statistics()


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
