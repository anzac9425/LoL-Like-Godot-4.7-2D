extends RefCounted
class_name DamageInstance


var damage_type: DamageType.Type
var source_type: SourceType.Type

var amount: float

var allow_critical: bool
var allow_lifesteal: bool


static func create(
	damage_type_: DamageType.Type,
	source_type_: SourceType.Type,
	amount_: float,
	allow_critical_: bool,
	allow_lifesteal_: bool
	) -> DamageInstance:
		
	var instance: DamageInstance = DamageInstance.new()

	instance.damage_type = damage_type_
	instance.source_type = source_type_
	instance.amount = amount_
	instance.allow_critical = allow_critical_
	instance.allow_lifesteal = allow_lifesteal_

	return instance
