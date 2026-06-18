extends CharacterLogic


var spellblade: bool

var spellblade_cooldown: Cooldown = Cooldown.new()
var spellblade_duration: Cooldown = Cooldown.new()


func _physics_process(delta: float) -> void:
	if spellblade_cooldown.remaining_duration > 0.0:
		var old: float = spellblade_cooldown.remaining_duration

		spellblade_cooldown.remaining_duration -= delta

		if old > 0.0 and spellblade_cooldown.remaining_duration <= 0.0:
			character_base.calculate_statistics()

	if spellblade_duration.remaining_duration > 0.0:
		spellblade_duration.remaining_duration -= delta

		if spellblade_duration.remaining_duration <= 0.0:
			spellblade = false
			
			character_base.calculate_statistics()


func on_hit(damage_info: DamageInfo):
	if spellblade:
		spellblade = false
		spellblade_duration.remaining_duration = 0.0

		damage_info.add_damage_instance(
			DamageType.Type.PHYSICAL,
			SourceType.Type.ITEM,
			0.75 * character_base.base_statistics.attack_damage
			+ 0.45 * character_base.total_statistics.ability_power,
			false,
			true
		)

		spellblade_cooldown.remaining_duration = 1.5
		
		character_base.calculate_statistics()


func build_damage_info(_damage_info: DamageInfo) -> void:
	pass


func modify_base_statistics(_base_statistics: Statistics) -> void:
	pass


func modify_bonus_statistics(_base_statistics: Statistics, bonus_statistics: Statistics) -> void:
	if spellblade_cooldown.remaining_duration <= 0:
		bonus_statistics.attack_speed_multiplier += 0.5


func modify_total_statistics(_base_statistics: Statistics, _bonus_statistics: Statistics, _raw_total_statistics: Statistics) -> void:
	pass


func on_deal_damage(_damage_info: DamageInfo) -> void:
	pass


func on_take_damage(_damage_info: DamageInfo) -> void:
	pass


func on_deal_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_take_projectile_hit(_projectile: Projectile) -> void:
	pass


func on_cast(_source_type: SourceType.Type):
	if spellblade:
		spellblade_duration.remaining_duration = 10.0
		return

	if spellblade_cooldown.remaining_duration > 0.0:
		return

	spellblade = true
	spellblade_duration.remaining_duration = 10.0
	
	character_base.calculate_statistics()
