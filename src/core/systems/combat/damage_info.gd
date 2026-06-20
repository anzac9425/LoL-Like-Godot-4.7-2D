extends RefCounted
class_name DamageInfo


var attacker: CharacterBase
var victim: CharacterBase

var damage_instances: Array[DamageInstance]

var on_hit: bool
var on_hit_count: int = 1

var is_dot: bool

var cast_id: String

var was_crit: bool


static func generate_cast_id() -> String:
	return str(Time.get_ticks_usec(), "_", randi())


static func create(attacker_: CharacterBase, victim_: CharacterBase, cast_id_: String, is_dot_: bool = false) -> DamageInfo:
	var instance: DamageInfo = DamageInfo.new()

	instance.attacker = attacker_
	instance.victim = victim_
	instance.cast_id = cast_id_
	instance.is_dot = is_dot_

	return instance


func duplicate() -> DamageInfo:
	var copy: DamageInfo = DamageInfo.create(attacker, victim, cast_id, is_dot)

	copy.on_hit = on_hit
	copy.on_hit_count = on_hit_count
	copy.was_crit = was_crit

	for instance in damage_instances:
		copy.add_damage_instance(
			instance.damage_type,
			instance.source_type,
			instance.amount,
			instance.allow_critical,
			instance.allow_lifesteal
		)

	return copy


func add_damage_instance(
	damage_type: DamageType.Type,
	source_type: SourceType.Type,
	amount: float,
	allow_critical: bool,
	allow_lifesteal: bool
	) -> DamageInstance:
		
	var instance: DamageInstance = DamageInstance.new()

	instance.damage_type = damage_type
	instance.source_type = source_type
	instance.amount = amount
	instance.allow_critical = allow_critical
	instance.allow_lifesteal = allow_lifesteal

	damage_instances.append(instance)
	
	return instance
