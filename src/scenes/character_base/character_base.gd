extends Area2D
class_name CharacterBase


@onready var character_sprite: Sprite2D = $Sprite2D
@onready var character_collision_shape: CollisionShape2D = $CollisionShape2D

var character_data: CharacterData
var character_logic: CharacterLogic

var base_statistics: Statistics = Statistics.new()
var bonus_statistics: Statistics = Statistics.new()
var total_statistics: Statistics = Statistics.new()

var team: String

var is_dead: bool

var level: int = 17
var experience: float

var current_health: float
var current_mana: float
var barriers: Array[Barrier]

var crowd_controls: Array[CrowdControl]
var statuses: Array[Status]

var items: Array[ItemData]
var item_logics: Array[CharacterLogic]

var runes: Array[RuneData]
var rune_logics: Array[CharacterLogic]

var effects: Array[Effect]

var character_radius: float
var character_sprite_radius: float
var character_collision_shape_radius: float

var is_moving: bool
var target_position: Vector2

var forced_movement: ForcedMovement

var auto_attack_target: CharacterBase
var auto_attack_available: bool = true
var auto_attack_cooldown: Cooldown = Cooldown.new()
var auto_attack_cast_time: Cooldown = Cooldown.new()


func _ready() -> void:
	character_logic = character_data.character_logic.new()
	character_logic.name = "CharacterLogic"
	character_logic.character_base = self
	add_child(character_logic)

	calculate_statistics()

	respawn()
	
	
func _physics_process(delta: float) -> void:
	Combat.apply_heal(self, total_statistics.health_regeneration / 5 * delta)
	Combat.apply_mana_restore(self, total_statistics.mana_regeneration / 5 * delta)
	
	if forced_movement:
		var movement: ForcedMovement = forced_movement

		if movement.target:
			if movement.target.is_dead:
				forced_movement = null

			else:
				movement.destination = movement.target.global_position

		if forced_movement:
			global_position = global_position.move_toward(
				movement.destination,
				movement.speed * delta
			)

			if global_position == movement.destination:
				forced_movement = null
				
	if is_moving:
		if !forced_movement:
			if can_move():
				global_position = global_position.move_toward(target_position, total_statistics.move_speed * delta)
				
				if global_position == target_position:
					is_moving = false
	
	if barriers:
		for i in range(barriers.size() - 1, -1, -1):
			var barrier: Barrier = barriers[i]

			barrier.remaining_duration -= delta

			if barrier.remaining_duration <= 0.0:	
				barriers.remove_at(i)
				
				queue_redraw()
	
	if crowd_controls:
		for i in range(crowd_controls.size() - 1, -1, -1):
			var crowd_control: CrowdControl = crowd_controls[i]

			crowd_control.remaining_duration -= delta

			if crowd_control.remaining_duration <= 0.0:
				crowd_controls.remove_at(i)
				
				if crowd_control.type == CrowdControl.Type.SLOW:
					calculate_statistics()
	
	if statuses:
		for i in range(statuses.size() - 1, -1, -1):
			var status: Status = statuses[i]

			status.remaining_duration -= delta

			if status.remaining_duration <= 0.0:
				statuses.remove_at(i)
	
	if effects:
		for i in range(effects.size() - 1, -1, -1):
			var effect: Effect = effects[i]

			effect.remaining_duration -= delta

			if effect.remaining_duration <= 0.0:
				effects.remove_at(i)

				calculate_statistics()
	
	if auto_attack_cooldown.remaining_duration > 0.0:
		auto_attack_cooldown.remaining_duration -= delta
	
	if auto_attack_cast_time.remaining_duration > 0.0:
		auto_attack_cast_time.remaining_duration -= delta

		if auto_attack_cast_time.remaining_duration <= 0.0:
			_auto_attack()

	if auto_attack_target:
		if !auto_attack_target.can_be_targeted():
			auto_attack_target = null

		else:
			var distance: float = global_position.distance_to(auto_attack_target.global_position)

			var attack_distance: float = (
				total_statistics.attack_range
				+ character_collision_shape_radius
				+ auto_attack_target.character_collision_shape_radius
			)

			if distance > attack_distance:
				move_to(auto_attack_target.global_position, false)

			else:
				is_moving = false
				
				if auto_attack_cooldown.remaining_duration <= 0.0:
					if auto_attack_cast_time.remaining_duration <= 0.0:
						auto_attack()


func _draw() -> void:
	if is_dead:
		return
		
	var width: float = 256.0
	var height: float = 32.0
	var mana_height: float = 8.0
	
	var barrier_amount: float = 0.0
	
	for barrier in barriers:
		barrier_amount += barrier.amount
		
	var max_health_barrier: float = max(total_statistics.health, current_health + barrier_amount)

	var health_ratio: float = current_health / max_health_barrier

	var pos: Vector2 = Vector2(width / -2, -128.0)
	var mana_pos: Vector2 = Vector2(width / -2, -128.0 + height + 4.0)

	draw_rect(Rect2(pos, Vector2(width, height)), Color.BLACK)

	draw_rect(Rect2(pos, Vector2(width * health_ratio, height)), Color.RED)

	if barrier_amount > 0.0:
		var current_x: float = pos.x + width * health_ratio

		for barrier in barriers:
			var barrier_width: float = (barrier.amount / max_health_barrier) * width

			var color: Color

			match barrier.type:
				Barrier.Type.NORMAL:
					color = Color.YELLOW

				Barrier.Type.PHYSICAL:
					color = Color.ORANGE

				Barrier.Type.MAGIC:
					color = Color.PURPLE

				_:
					color = Color.WHITE

			draw_rect(Rect2(Vector2(current_x, pos.y), Vector2(barrier_width, height)), color)

			current_x += barrier_width

	if total_statistics.mana > 0:
		var mana_ratio: float = current_mana / total_statistics.mana

		draw_rect(Rect2(mana_pos, Vector2(width, mana_height)), Color.BLACK)

		draw_rect(Rect2(mana_pos, Vector2(width * mana_ratio, mana_height)), Color.BLUE)

		draw_rect(Rect2(mana_pos, Vector2(width, mana_height)), Color.WHITE, false, 1.0)

	if total_statistics.health:
		for hp in range(100, int(max_health_barrier), 100):
			var x: float = pos.x + (float(hp) / max_health_barrier) * width

			draw_line(Vector2(x, pos.y + height * 0.5), Vector2(x, pos.y), Color.BLACK, 1.0)

	if max_health_barrier > 1000:
		for hp in range(1000, int(max_health_barrier), 1000):
			var x: float = pos.x + (float(hp) / max_health_barrier) * width

			draw_line(Vector2(x, pos.y), Vector2(x, pos.y + height), Color.BLACK, 2.0)

	draw_rect(Rect2(pos, Vector2(width, height)), Color.WHITE, false, 2.0)


func die() -> void:
	if !can_die():
		return
	
	is_dead = true
	
	is_moving = false
	forced_movement = null
	
	auto_attack_available = false
	auto_attack_target = null

	set_physics_process(false)
	update_visibility()
	queue_redraw()

	
func respawn() -> void:
	is_dead = false
	auto_attack_available = true

	current_health = total_statistics.health
	current_mana = total_statistics.mana

	barriers.clear()
	crowd_controls.clear()
	statuses.clear()
	effects.clear()

	target_position = global_position

	is_moving = false
	forced_movement = null
	
	auto_attack_target = null

	set_physics_process(true)

	update_visibility()
	queue_redraw()


func set_radius_sprite(radius: float) -> void:
	character_sprite.scale = Vector2.ONE * (
		radius * 2.0 / character_sprite.texture.get_size().x
	)
	
	character_sprite_radius = radius


func set_radius_collision_shape(radius: float) -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	
	shape.radius = radius

	character_collision_shape.shape = shape
	
	character_collision_shape_radius = radius


func on_hit(damage_info: DamageInfo):
	for rune_logic in rune_logics:
		rune_logic.on_hit(damage_info)

	for item_logic in item_logics:
		item_logic.on_hit(damage_info)

	character_logic.on_hit(damage_info)


func build_damage_info(damage_info: DamageInfo) -> void:
	for rune_logic in rune_logics:
		rune_logic.build_damage_info(damage_info)

	for item_logic in item_logics:
		item_logic.build_damage_info(damage_info)
		
	character_logic.build_damage_info(damage_info)


func on_deal_damage(damage_info: DamageInfo):
	for rune_logic in rune_logics:
		rune_logic.on_deal_damage(damage_info)

	for item_logic in item_logics:
		item_logic.on_deal_damage(damage_info)

	character_logic.on_deal_damage(damage_info)


func on_take_damage(damage_info: DamageInfo):
	for rune_logic in rune_logics:
		rune_logic.on_take_damage(damage_info)

	for item_logic in item_logics:
		item_logic.on_take_damage(damage_info)

	character_logic.on_take_damage(damage_info)


func on_deal_projectile_hit(projectile: Projectile):
	for rune_logic in rune_logics:
		rune_logic.on_deal_projectile_hit(projectile)

	for item_logic in item_logics:
		item_logic.on_deal_projectile_hit(projectile)

	character_logic.on_deal_projectile_hit(projectile)


func on_take_projectile_hit(projectile: Projectile):
	for rune_logic in rune_logics:
		rune_logic.on_take_projectile_hit(projectile)

	for item_logic in item_logics:
		item_logic.on_take_projectile_hit(projectile)

	character_logic.on_take_projectile_hit(projectile)


func on_lethal_damage(damage_info: DamageInfo) -> bool:
	for rune_logic in rune_logics:
		if rune_logic.on_lethal_damage(damage_info):
			return true

	for item_logic in item_logics:
		if item_logic.on_lethal_damage(damage_info):
			return true

	if character_logic.on_lethal_damage(damage_info):
		return true

	return false


func on_cast(source_type: SourceType.Type):
	var cast_id: String = DamageInfo.generate_cast_id()

	var success: bool

	match source_type:
		SourceType.Type.SKILL_Q:
			success = character_logic.cast_q(cast_id)

		SourceType.Type.SKILL_W:
			success = character_logic.cast_w(cast_id)

		SourceType.Type.SKILL_E:
			success = character_logic.cast_e(cast_id)

		SourceType.Type.SKILL_R:
			success = character_logic.cast_r(cast_id)
	
	if !success:
		return
	
	for rune_logic in rune_logics:
		rune_logic.on_cast(source_type)
		
	for item_logic in item_logics:
		item_logic.on_cast(source_type)


func auto_attack():
	if !can_auto_attack():
		return

	auto_attack_cast_time.remaining_duration = character_data.auto_attack_windup_multiplier / total_statistics.attack_speed

	auto_attack_cooldown.remaining_duration = 1.0 / total_statistics.attack_speed


func _auto_attack():
	if !auto_attack_target:
		return
	if !auto_attack_target.can_be_targeted():
		return
		
	var damage_info: DamageInfo = DamageInfo.create(self, auto_attack_target, DamageInfo.generate_cast_id())
	
	damage_info.add_damage_instance(
		DamageType.Type.PHYSICAL,
		SourceType.Type.AUTO_ATTACK,
		total_statistics.attack_damage,
		true,
		true
	)
	
	damage_info.on_hit = true
	
	if character_data.ranged:
		Ingame.current.spawn_projectile(
			damage_info,
			Projectile.Type.TARGET,
			total_statistics.attack_projectile_speed,
			8.0
		)
		
	else:
		Combat.apply_damage(damage_info)


func move_to(pos: Vector2, cancel_attack: bool) -> void:
	target_position = pos
	is_moving = true
	
	if cancel_attack:
		if auto_attack_cast_time.remaining_duration > 0:
			auto_attack_cast_time.remaining_duration = 0.0
			auto_attack_cooldown.remaining_duration = 0.0
	

func stop():
	is_moving = false

	auto_attack_target = null
	
	if auto_attack_cast_time.remaining_duration > 0:
		auto_attack_cast_time.remaining_duration = 0.0
		auto_attack_cooldown.remaining_duration = 0.0


func update_visibility() -> void:
	character_sprite.visible = !is_dead


func add_item(item_data: ItemData):
	items.append(item_data)

	if item_data.item_logic:
		var logic: CharacterLogic = item_data.item_logic.new()

		logic.character_base = self

		item_logics.append(logic)
		add_child(logic)

	calculate_statistics()


func add_rune(rune_data: RuneData):
	runes.append(rune_data)

	if rune_data.rune_logic:
		var logic: CharacterLogic = rune_data.rune_logic.new()

		logic.character_base = self

		rune_logics.append(logic)
		add_child(logic)

	calculate_statistics()


func is_same_team(target: CharacterBase) -> bool:
	return team == target.team


func is_enemy_team(target: CharacterBase) -> bool:
	return team != target.team


func has_crowd_control(type: CrowdControl.Type) -> bool:
	for crowd_control in crowd_controls:
		if crowd_control.type == type:
			return true

	return false


func has_status(type: Status.Type) -> bool:
	for status in statuses:
		if status.type == type:
			return true

	return false


func has_effect(type: Effect.Type) -> bool:
	for effect in effects:
		if effect.type == type:
			return true

	return false


func get_effect_amount(type: Effect.Type) -> float:
	var amount: float

	for effect in effects:
		if effect.type == type:
			amount = max(amount, effect.amount)

	return amount


func can_move() -> bool:
	if is_dead:
		return false

	if has_crowd_control(CrowdControl.Type.STUN):
		return false

	if has_crowd_control(CrowdControl.Type.ROOT):
		return false
	
	if has_crowd_control(CrowdControl.Type.AIRBORNE):
		return false
	
	if has_status(Status.Type.CANNOT_MOVE):
		return false

	return true


func can_auto_attack() -> bool:
	if is_dead:
		return false
	
	if !auto_attack_available:
		return false
		
	if has_crowd_control(CrowdControl.Type.STUN):
		return false
	
	if has_crowd_control(CrowdControl.Type.AIRBORNE):
		return false
	
	if has_status(Status.Type.CANNOT_AUTO_ATTACK):
		return false
	
	if forced_movement:
		return false
		
	return true


func can_cast():
	if is_dead:
		return false
	
	if has_crowd_control(CrowdControl.Type.STUN):
		return false

	if has_crowd_control(CrowdControl.Type.SILENCE):
		return false
	
	if has_crowd_control(CrowdControl.Type.AIRBORNE):
		return false
	
	if has_status(Status.Type.CANNOT_CAST):
		return false

	return true


func can_be_targeted() -> bool:
	if is_dead:
		return false
	
	if has_status(Status.Type.UNTARGETABLE):
		return false
	
	if has_status(Status.Type.CANNOT_BE_TARGETED):
		return false
		
	return true


func can_take_damage():
	if is_dead:
		return false
		
	if has_status(Status.Type.INVULNERABLE):
		return false
	
	if has_status(Status.Type.CANNOT_TAKE_DAMAGE):
		return false

	return true


func can_be_crowd_controlled():
	if is_dead:
		return false
	
	if has_status(Status.Type.UNSTOPPABLE):
		return false
	
	if has_status(Status.Type.CANNOT_BE_CROWD_CONTROLLED):
		return false
	
	return true

func can_die():
	if is_dead:
		return false
	
	if has_status(Status.Type.UNDYING):
		return false
	
	if has_status(Status.Type.CANNOT_DIE):
		return false
	
	return true


func calculate_statistics() -> void:
	var old_total_statistics_health: float = total_statistics.health
	
	base_statistics = Statistics.new()
	
	var growthed_statistics: Statistics = character_data.growth_statistics.duplicate()
	
	growthed_statistics.multiply(level)
	
	base_statistics.add(character_data.statistics)
	base_statistics.add(growthed_statistics)
	
	for rune_logic in rune_logics:
		rune_logic.modify_base_statistics(base_statistics)
	
	for item_logic in item_logics:
		item_logic.modify_base_statistics(base_statistics)
	
	character_logic.modify_base_statistics(base_statistics)
	
	bonus_statistics = Statistics.new()

	for item in items:
		if item.statistics:
			bonus_statistics.add(item.statistics)
	
	for rune_logic in rune_logics:
		rune_logic.modify_bonus_statistics(base_statistics, bonus_statistics)
	
	for item_logic in item_logics:
		item_logic.modify_bonus_statistics(base_statistics, bonus_statistics)
	
	character_logic.modify_bonus_statistics(base_statistics, bonus_statistics)
	
	if bonus_statistics.attack_damage >= bonus_statistics.ability_power:
		bonus_statistics.attack_damage += bonus_statistics.adaptive_force * 0.6
		
	else:
		bonus_statistics.ability_power += bonus_statistics.adaptive_force
	
	var raw_total_statistics = Statistics.new()
	
	raw_total_statistics.add(base_statistics)
	raw_total_statistics.add(bonus_statistics)
	
	for rune_logic in rune_logics:
		rune_logic.modify_total_statistics(base_statistics, bonus_statistics, raw_total_statistics)
	
	for item_logic in item_logics:
		item_logic.modify_total_statistics(base_statistics, bonus_statistics, raw_total_statistics)
		
	character_logic.modify_total_statistics(base_statistics, bonus_statistics, raw_total_statistics)
	
	total_statistics = Statistics.new()
	
	total_statistics.add(base_statistics)
	total_statistics.add(bonus_statistics)
	
	total_statistics.attack_speed *= 1.0 + total_statistics.attack_speed_multiplier
	total_statistics.move_speed *= 1.0 + total_statistics.move_speed_multiplier
	
	var slow_amount: float
	
	for crowd_control in crowd_controls:
		if crowd_control.type == CrowdControl.Type.SLOW:
			slow_amount = max(slow_amount,crowd_control.amount)
	
	total_statistics.move_speed *= (1.0 - slow_amount)

	total_statistics.armor -= get_effect_amount(Effect.Type.ARMOR_REDUCTION)

	total_statistics.magic_resistance -= get_effect_amount(Effect.Type.MAGIC_RESISTANCE_REDUCTION)
	
	current_health += max(0.0, total_statistics.health - old_total_statistics_health)
	
	current_health = min(current_health, total_statistics.health)
	
	set_radius_sprite(total_statistics.radius)
	set_radius_collision_shape(total_statistics.radius)
	
	queue_redraw()
