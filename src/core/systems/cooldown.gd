class_name Cooldown

enum Type {
	SKILL,
	ULTIMATE,
	ITEM
}

var remaining_duration: float

func start(base_duration: float, type: Type, stats: Statistics):
	var haste: float = 0.0

	match type:
		Type.SKILL:
			haste = stats.skill_haste

		Type.ULTIMATE:
			haste = stats.skill_haste + stats.ultimate_haste

		Type.ITEM:
			haste = stats.item_haste

	remaining_duration = base_duration / (1.0 + haste / 100.0)
