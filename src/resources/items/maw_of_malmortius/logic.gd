extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()
var duration: Cooldown = Cooldown.new()
var active: bool


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta
	
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			active = false
			
			character_base.calculate_statistics()


func on_attack(_damage_info: DamageInfo) -> void:
	pass


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if active:
		bonus_statistics.omnivamp += 0.1


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(_damage_info: DamageInfo) -> void:
	if active:
		duration.remaining_duration = 5.0


func on_take_damage(damage_info: DamageInfo) -> void:
	if active:
		duration.remaining_duration = 5.0
	
	if cooldown.remaining_duration > 0:
		return
	
	if character_base.current_health / character_base.total_statistics.health >= 0.3:
		return
	
	for instance in damage_info.damage_instances:
		match instance.damage_type:
			DamageType.Type.MAGIC:
				active = true
	
	if !active:
		return
	
	cooldown.start(90.0, Cooldown.Type.ITEM, character_base.total_statistics)
	duration.remaining_duration = 5.0
	
	if character_base.character_data.ranged:
		Combat.apply_barrier(character_base, 150.0 + 1.125 * character_base.total_statistics.attack_damage, 3.0, Barrier.Type.MAGIC)
	
	else:
		Combat.apply_barrier(character_base, 200.0 + 1.5 * character_base.total_statistics.attack_damage, 3.0, Barrier.Type.MAGIC)
	
	character_base.calculate_statistics()


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func on_cast(_source_type: SourceType.Type) -> void:
	pass
