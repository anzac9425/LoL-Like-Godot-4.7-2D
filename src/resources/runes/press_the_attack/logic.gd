extends CharacterLogic


var stack: Stack
var duration: Cooldown = Cooldown.new()
var target: CharacterBase


func _physics_process(delta: float):
	if stack:
		stack.cooldown.remaining_duration -= delta

		if stack.cooldown.remaining_duration <= 0.0:
			stack = null
	
	if duration.remaining_duration > 0.0:
		duration.remaining_duration -= delta

		if duration.remaining_duration <= 0.0:
			target = null


func on_hit(damage_info: DamageInfo) -> void:
	if !stack:
		stack = Stack.new()
		stack.target = damage_info.victim

	elif stack.target != damage_info.victim:
		stack = Stack.new()
		stack.target = damage_info.victim
	
	if target == damage_info.victim:
		duration.remaining_duration = 5.0
		return

	stack.stack += 1
	stack.cooldown.remaining_duration = 4.0
	
	if stack.stack < 3:
		return
	
	var damage: float = 40.0 + 120.0 / 17.0 * character_base.level
	
	var damage_type: DamageType.Type
	
	if character_base.bonus_statistics.attack_damage >= character_base.bonus_statistics.ability_power:
		damage_type = DamageType.Type.PHYSICAL

	else:
		damage_type = DamageType.Type.MAGIC

	damage_info.add_damage_instance(
		damage_type,
		SourceType.Type.RUNE,
		damage,
		false,
		false
	)
	
	target = damage_info.victim
	duration.remaining_duration = 5.0

	stack = null


func build_damage_info(damage_info: DamageInfo):
	if damage_info.attacker != character_base:
		return

	if target != damage_info.victim:
		return

	if duration.remaining_duration <= 0.0:
		return
	
	for instance in damage_info.damage_instances:
		instance.amount *= 1.08


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
