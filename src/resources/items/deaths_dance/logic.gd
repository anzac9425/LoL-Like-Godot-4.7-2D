extends CharacterLogic


var damage_infos: Array[DamageInfo]
var raw_damage_infos: Array[DamageInfo]


func _physics_process(delta: float) -> void:
	for i in range(damage_infos.size() - 1, -1, -1):
		var damage_info: DamageInfo = damage_infos[i]
		var raw_damage_info: DamageInfo = raw_damage_infos[i]

		var tick_damage: DamageInfo = DamageInfo.create(
			damage_info.attacker,
			damage_info.victim,
			damage_info.cast_id,
			true
		)

		var finished: bool = true

		for j in range(damage_info.damage_instances.size()):
			var instance: DamageInstance = damage_info.damage_instances[j]
			var raw_instance: DamageInstance = raw_damage_info.damage_instances[j]

			if instance.amount <= 0.0:
				continue

			var amount: float = min(instance.amount, raw_instance.amount * delta / 3.0)

			tick_damage.add_damage_instance(
				instance.damage_type,
				instance.source_type,
				amount,
				instance.allow_critical,
				instance.allow_lifesteal
			)

			instance.amount -= amount

			if instance.amount > 0.0:
				finished = false
		
		if tick_damage.damage_instances:
			Combat.apply_damage(tick_damage)

		if finished:
			damage_infos.remove_at(i)
			raw_damage_infos.remove_at(i)


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	var damage_info_: DamageInfo = DamageInfo.create(damage_info.attacker,damage_info.victim, damage_info.cast_id)
	
	for instance in damage_info.damage_instances:
		damage_info_.add_damage_instance(instance.damage_type, instance.source_type, instance.amount * 0., instance.allow_critical, instance.allow_lifesteal)
		damage_info_.on_hit = damage_info.on_hit
		damage_info_.on_hit_count = damage_info.on_hit_count
		damage_info_.is_dot = damage_info.is_dot
	
	damage_infos.append(damage_info)
	raw_damage_infos.append(damage_info_)


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


func on_cast(_source_type: SourceType.Type):
	pass
