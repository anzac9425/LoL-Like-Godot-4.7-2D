extends RefCounted
class_name Status

enum Type {
	UNTARGETABLE,
	INVULNERABLE,
	UNDYING,
	UNSTOPPABLE
}

var type: Type
var remaining_duration: float
