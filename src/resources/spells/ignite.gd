extends Spell
class_name Ignite

func cast(caster: CharacterBase) -> bool:
	if cooldown.remaining_duration > 0:
		return false
	
	var target: CharacterBase = Ingame.current.get_target_at_mouse_position()

	if !target:
		return false

	if target == caster:
		return false

	if !caster.is_enemy_team(target):
		return false

	if target.is_dead:
		return false

	if !target.can_be_targeted():
		return false

	if caster.global_position.distance_to(target.global_position) > (
		600.0
		+ caster.character_collision_shape_radius
		+ target.character_collision_shape_radius
	):
		return false

	var damage_info: DamageInfo = DamageInfo.create(caster, target, DamageInfo.generate_cast_id())

	damage_info.add_damage_instance(DamageType.Type.TRUE, SourceType.Type.SPELL, 70.0 + 405.0 / 17.0 * target.level, false, false)

	damage_info.is_dot = true
	
	Combat.apply_effect(target, Effect.Type.DOT, 5.0, 5.0, damage_info)
	
	Combat.apply_effect(target, Effect.Type.HEAL_REDUCTION, 5.0, 0.4)

	cooldown.start(180.0, Cooldown.Type.SPELL, target.total_statistics)

	return true
