extends CharacterLogic


var areas: Array[Area]
var cooldowns: Array[Cooldown]
var cast_ids: Array[String]
var affected_targets: Array[CharacterBase]


func _physics_process(delta: float) -> void:
	for i in range(areas.size() - 1, -1, -1):
		cooldowns[i].remaining_duration -= delta

		if cooldowns[i].remaining_duration <= 0.0:
			areas[i].queue_free()

			areas.remove_at(i)
			cooldowns.remove_at(i)
			cast_ids.remove_at(i)

			continue

		for target in areas[i].get_targets():
			if !target.is_enemy_team(character_base):
				continue
				
			Combat.apply_effect(target, Effect.Type.MAGIC_RESISTANCE_REDUCTION, 0.1, 10)
			
			var damage_info: DamageInfo = DamageInfo.create(
				character_base,
				target,
				cast_ids[i],
				true
			)

			damage_info.add_damage_instance(
				DamageType.Type.MAGIC,
				SourceType.Type.ITEM,
				(60.0 + 0.05 * character_base.total_statistics.ability_power) * delta,
				false,
				false
			)

			Combat.apply_damage(damage_info)


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


func on_deal_damage(damage_info: DamageInfo) -> void:
	for instance in damage_info.damage_instances:
		if instance.source_type == SourceType.Type.SKILL_R:
			var area: Area = Area.create_circle(damage_info.victim.global_position, 300.0, true)

			add_child(area)

			areas.append(area)

			var cooldown: Cooldown = Cooldown.new()
			cooldown.remaining_duration = 3.0

			cooldowns.append(cooldown)

			cast_ids.append(DamageInfo.generate_cast_id())
			
			return


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
