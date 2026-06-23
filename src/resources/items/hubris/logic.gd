extends CharacterLogic


var duration: Cooldown = Cooldown.new()
var amount: int


func _physics_process(delta: float) -> void:
	if duration.remaining_duration > 0:
		duration.remaining_duration -= delta
		
		if duration.remaining_duration <= 0:
			amount = 0
			
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
	if duration.remaining_duration > 0:
		bonus_statistics.attack_damage += 12 + 3 * amount


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.victim.is_dead:
		duration.remaining_duration = 90.0
		
		amount += 1
		
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
