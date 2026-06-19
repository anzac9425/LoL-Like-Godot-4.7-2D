extends CharacterLogic


var damage_infos: Array[DamageInfo]
var raw_damage_infos: Array[DamageInfo]

var heal_remaining: float
var heal_duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	var tick_damages: Array[DamageInfo]

	for i in range(damage_infos.size() - 1, -1, -1):
		var damage_info: DamageInfo = damage_infos[i]
		var raw_damage_info: DamageInfo = raw_damage_infos[i]

		var tick_damage: DamageInfo = null

		for info in tick_damages:
			if info.attacker == damage_info.attacker:
				tick_damage = info
				break

		if !tick_damage:
			tick_damage = DamageInfo.create(
				damage_info.attacker,
				damage_info.victim,
				damage_info.cast_id,
				true
			)

			tick_damage.is_dot = true

			tick_damages.append(tick_damage)

		var finished: bool = true

		for j in range(damage_info.damage_instances.size()):
			var instance: DamageInstance = damage_info.damage_instances[j]
			var raw_instance: DamageInstance = raw_damage_info.damage_instances[j]

			if instance.amount <= 0.0:
				continue

			var amount: float = min(instance.amount, raw_instance.amount * delta / 3.0)
			
			tick_damage.add_damage_instance(
				instance.damage_type,
				SourceType.Type.ITEM,
				amount,
				false,
				false
			)

			instance.amount -= amount

			if instance.amount > 0.0:
				finished = false

		if finished:
			damage_infos.remove_at(i)
			raw_damage_infos.remove_at(i)

	for tick_damage in tick_damages:
		if tick_damage.damage_instances.size() > 0:
			Combat.apply_damage(tick_damage)
	
	if heal_duration.remaining_duration > 0.0:
		var heal: float = min(heal_remaining, heal_remaining * delta / heal_duration.remaining_duration)

		Combat.apply_heal(character_base, heal)

		heal_remaining -= heal
		heal_duration.remaining_duration -= delta


func clear():
	damage_infos.clear()
	raw_damage_infos.clear()


func on_hit(_damage_info: DamageInfo) -> void:
	pass


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.is_dot:
		return
	
	if damage_info.victim != character_base:
		return
	
	var amount: float
	
	if character_base.character_data.ranged:
		amount = 0.1
	
	else:
		amount = 0.3
	
	for instance in damage_info.damage_instances:
		instance.amount *= (1 - amount)
	
	var damage_info_: DamageInfo = damage_info.duplicate()
	
	for instance in damage_info_.damage_instances:
		instance.amount *= amount
	
	damage_infos.append(damage_info_)
	raw_damage_infos.append(damage_info_.duplicate())


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics) -> void:
	pass


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(damage_info: DamageInfo) -> void:
	if damage_info.victim.is_dead:
		var heal_amount: float = character_base.bonus_statistics.attack_damage * 0.75

		heal_remaining += heal_amount
		heal_duration.remaining_duration = 2.0

		clear.call_deferred()


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	pass
