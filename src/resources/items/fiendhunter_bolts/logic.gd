extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()
var duration: Cooldown = Cooldown.new()
var stack: int


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			stack = 0
			
			character_base.calculate_statistics()


func on_attack(damage_info: DamageInfo) -> void:
	if stack <= 0:
		return
	
	stack -= 1
	
	damage_info.was_crit = true
	
	for i in range(damage_info.damage_instances.size() - 1, -1, -1):
		var instance = damage_info.damage_instances[i]
		
		instance.allow_critical = false
		
		if randf() < character_base.total_statistics.critical_chance:
			instance.amount *= character_base.total_statistics.critical_damage_multiplier
			
			damage_info.add_damage_instance(DamageType.Type.TRUE, SourceType.Type.ITEM, 0.15 * instance.amount, false, false)
		
		else:
			instance.amount *= 0.8 * character_base.total_statistics.critical_damage_multiplier
	
	if stack <= 0:
		duration.remaining_duration = 0.0


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if duration.remaining_duration > 0:
		bonus_statistics.attack_speed_multiplier += 0.5


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
	if cooldown.remaining_duration <= 0:
		if source_type == SourceType.Type.SKILL_R:
			cooldown.start(45.0, Cooldown.Type.ITEM, character_base.total_statistics)
			duration.remaining_duration = 8.0
			stack = 3
			
			character_base.calculate_statistics()
