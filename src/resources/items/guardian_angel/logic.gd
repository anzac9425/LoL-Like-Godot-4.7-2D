extends CharacterLogic


var cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta


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
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_lethal_damage(damage_info: DamageInfo) -> bool:
	if cooldown.remaining_duration > 0.0:
		return false

	cooldown.remaining_duration = 300.0

	revive(damage_info.victim)

	return true


func revive(target: CharacterBase) -> void:
	Combat.apply_status(target, Status.Type.UNTARGETABLE, 4.0)
	Combat.apply_status(target, Status.Type.INVULNERABLE, 4.0)
	Combat.apply_status(target, Status.Type.CANNOT_MOVE, 4.0)
	Combat.apply_status(target, Status.Type.CANNOT_AUTO_ATTACK, 4.0)
	Combat.apply_status(target, Status.Type.CANNOT_CAST, 4.0)
	Combat.apply_status(target, Status.Type.CANNOT_SPELL, 4.0)
	Combat.apply_status(target, Status.Type.CANNOT_BE_CROWD_CONTROLLED, 4.0)
	
	await get_tree().create_timer(4.0).timeout
	
	target.current_health = target.base_statistics.health * 0.5


func on_cast(_source_type: SourceType.Type):
	pass
