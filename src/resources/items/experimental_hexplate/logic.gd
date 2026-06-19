extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()
var duration: Cooldown = Cooldown.new()


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


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if duration.remaining_duration > 0:
		if character_base.character_data.ranged:
			bonus_statistics.attack_speed_multiplier += 0.35
			bonus_statistics.move_speed_multiplier += 0.14
		
		else:
			bonus_statistics.attack_speed_multiplier += 0.5
			bonus_statistics.move_speed_multiplier += 0.2


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


func on_cast(source_type: SourceType.Type) -> void:
	if cooldown.remaining_duration > 0:
		return
	
	if source_type != SourceType.Type.SKILL_R:
		return
	
	cooldown.start(30.0, Cooldown.Type.ITEM, character_base.total_statistics)
	
	duration.remaining_duration = 8.0
	
	character_base.calculate_statistics()
