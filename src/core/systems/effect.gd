class_name Effect

enum Type {
	HEAL_REDUCTION,
	ARMOR_REDUCTION,
	MAGIC_RESISTANCE_REDUCTION,
	BARRIER_REDUCTION
}

var type: Type
var amount: float
var remaining_duration: float
