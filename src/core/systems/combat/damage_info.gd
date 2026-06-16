extends RefCounted
class_name DamageInfo


var attacker: CharacterBase
var victim: CharacterBase

var damage_instances: Array[DamageInstance]

var on_hit: bool
var on_hit_count: int = 1


static func create(attacker_: CharacterBase, victim_: CharacterBase) -> DamageInfo:
	var instance: DamageInfo = DamageInfo.new()

	instance.attacker = attacker_
	instance.victim = victim_

	return instance
	
	
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
