extends RefCounted
class_name CrowdControl

enum Type {
	SLOW,
	STUN,
	ROOT,
	SILENCE
}

var type: Type
var amount: float
var remaining_duration: float
