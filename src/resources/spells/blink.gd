extends Spell
class_name Blink


func cast(target: CharacterBase) -> bool:
	if cooldown.remaining_duration > 0:
		return false
	
	if target.is_dead:
		return false
	
	if target.has_crowd_control(CrowdControl.Type.STUN):
		return false
	
	if target.has_crowd_control(CrowdControl.Type.ROOT):
		return false
	
	if target.has_crowd_control(CrowdControl.Type.SILENCE):
		return false
	
	if target.has_crowd_control(CrowdControl.Type.AIRBORNE):
		return false
	
	var destination: Vector2 = Ingame.current.get_global_mouse_position()

	if target.global_position.distance_to(destination) > 400:
		destination = target.global_position + (destination - target.global_position).normalized() * 400
	
	target.is_moving = false
	target.forced_movement = null
	target.global_position = destination

	cooldown.start(300.0, Cooldown.Type.SPELL, target.total_statistics)

	return true
