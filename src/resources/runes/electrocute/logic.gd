extends CharacterLogic

var instances: Array[Stack]
var cooldown: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0.0:
		cooldown.remaining_duration -= delta

	if instances:
		for i in range(instances.size() - 1, -1, -1):
			var instance: Stack = instances[i]

			instance.cooldown.remaining_duration -= delta

			if instance.cooldown.remaining_duration <= 0.0:
				instances.remove_at(i)


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
	if cooldown.remaining_duration > 0.0:
		return

	var instance: Stack

	for value in instances:
		if value.target == damage_info.victim:
			instance = value
			break

	if !instance:
		instance = Stack.new()
		instance.target = damage_info.victim

		instances.append(instance)

	if !damage_info.cast_id.is_empty():
		if damage_info.cast_id in instance.cast_ids:
			return

		instance.cast_ids.append(damage_info.cast_id)

	if instance.stack == 0:
		instance.cooldown.remaining_duration = 3.0

	instance.stack += 1

	if instance.stack < 3:
		return

	instances.erase(instance)

	cooldown.start(20.0, Cooldown.Type.ITEM, character_base.total_statistics)
	
	await get_tree().create_timer(0.25).timeout
	
	if damage_info.victim.is_dead:
		return

	var ad_damage: float = character_base.bonus_statistics.attack_damage * 0.10

	var ap_damage: float = character_base.total_statistics.ability_power * 0.05

	var damage: float = 70.0 + 190.0 / 17.0 * character_base.level + ad_damage + ap_damage

	var damage_type: DamageType.Type = DamageType.Type.MAGIC

	if ad_damage > ap_damage:
		damage_type = DamageType.Type.PHYSICAL
	
	var damage_info_: DamageInfo = DamageInfo.create(damage_info.attacker, damage_info.victim, DamageInfo.generate_cast_id())

	damage_info_.add_damage_instance(
		damage_type,
		SourceType.Type.RUNE,
		damage,
		false,
		false
	)
	
	Combat.apply_damage(damage_info_)


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
