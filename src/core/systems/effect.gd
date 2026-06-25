class_name Effect

enum Type {
	HEAL_REDUCTION,
	ARMOR_REDUCTION,
	MAGIC_RESISTANCE_REDUCTION,
	BARRIER_REDUCTION,
	DOT
}

var type: Type
var amount: float
var damage_info: DamageInfo
var remaining_duration: float
