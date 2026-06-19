extends RefCounted
class_name Barrier


enum Type {
	NORMAL,
	PHYSICAL,
	MAGIC
}

var type: Type
var amount: float
var remaining_duration: float
