extends CharacterLogic


func on_attack(damage_info: DamageInfo) -> void:
	var area: Area = Ingame.current.spawn_area(Area.create_circle(damage_info.victim.global_position, 375.0))

	var targets: Array[CharacterBase]

	for target in area.get_targets():
		if target == character_base:
			continue

		if target == damage_info.victim:
			continue

		if target.is_dead:
			continue

		targets.append(target)

	area.queue_free()

	targets.sort_custom(
		func(a: CharacterBase, b: CharacterBase):
			return (
				character_base.global_position.distance_squared_to(a.global_position)
				<
				character_base.global_position.distance_squared_to(b.global_position)
			)
	)

	var count: int = min(2, targets.size())

	for i in range(count):
		var damage_info_: DamageInfo = DamageInfo.create(
			damage_info.attacker,
			targets[i],
			damage_info.cast_id
		)

		damage_info_.on_hit = true

		damage_info_.add_damage_instance(
			DamageType.Type.PHYSICAL,
			SourceType.Type.ITEM,
			0.55 * character_base.total_statistics.attack_damage,
			true,
			true
		)

		Ingame.current.spawn_projectile(
			damage_info_,
			Projectile.Type.TARGET,
			2000.0,
			8.0
		)


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


func on_lethal_damage(_damage_info: DamageInfo) -> bool:
	return false


func on_cast(_source_type: SourceType.Type) -> void:
	pass
