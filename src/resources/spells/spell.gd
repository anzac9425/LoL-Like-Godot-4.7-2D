extends RefCounted
class_name Spell


enum Type {
	BLINK,
	IGNITE
}

var type: Type
var cooldown: Cooldown = Cooldown.new()
