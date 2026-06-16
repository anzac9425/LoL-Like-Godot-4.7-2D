extends CharacterLogic
class_name EclipseLogic


var cooldown: Cooldown = Cooldown.new()
var stacks: Array[Stack]
var last_source_types: Dictionary


func _physics_process(delta: float) -> void:
	if cooldown.remaining_duration > 0:
		cooldown.remaining_duration -= delta


func stack(target: CharacterBase) -> Stack:
	for stack_ in stacks:
		if stack_.target == target:
			return stack_

	var stack_: Stack = Stack.new()
	stack_.target = target

	stacks.append(stack_)

	return stack_


func build_damage_info(damage_info: DamageInfo) -> void:
	if damage_info.attacker != character_base:
		return
		
	if cooldown.remaining_duration > 0.0:
		return
	
	var source_type: SourceType.Type = SourceType.Type.UNKNOWN

	for instance in damage_info.damage_instances:
		source_type = instance.source_type
		break

	for instance in damage_info.damage_instances:
		if instance.source_type in [
			SourceType.Type.AUTO_ATTACK,
			SourceType.Type.SKILL_Q,
			SourceType.Type.SKILL_W,
			SourceType.Type.SKILL_E,
			SourceType.Type.SKILL_R
		]:
			source_type = instance.source_type
			break
	
	var last_source_type = last_source_types.get(
		damage_info.victim,
		SourceType.Type.UNKNOWN
	)

	if last_source_type == source_type:
		return

	last_source_types[damage_info.victim] = source_type
		

	var stack_: Stack = stack(damage_info.victim)

	stack_.stack += 1

	if stack_.stack < 2:
		return

	stack_.stack = 0

	cooldown.remaining_duration = 6.0
	
	var damage: float

	if character_base.character_data.ranged:
		damage = damage_info.victim.total_statistics.health * 0.04
		
	else:
		damage = damage_info.victim.total_statistics.health * 0.06

	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.ITEM,
		damage,
		false,
		false
	)
	
	var shield: float

	if character_base.character_data.ranged:
		shield = 80.0 + character_base.bonus_statistics.attack_damage * 0.2
		
	else:
		shield = 160.0 + character_base.bonus_statistics.attack_damage * 0.4

	Combat.apply_barrier(character_base, shield, 2.0)
	
	stacks.erase(stack_)
	last_source_types.erase(damage_info.victim)


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


func cast_q() -> void:
	pass


func cast_w() -> void:
	pass


func cast_e() -> void:
	pass


func cast_r() -> void:
	pass
