extends RefCounted
class_name DamageInstance


enum DamageType {
	PHYSICAL,
	MAGIC,
	TRUE
}

enum SourceType {
	UNKNOWN
}

var amount: float
var type: DamageType

var allow_critical: bool
var allow_lifesteal: bool

var source: SourceType
