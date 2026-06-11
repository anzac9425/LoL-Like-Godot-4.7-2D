extends Node2D
class_name Ingame


static var current: Ingame

var input_characters: Array[CharacterBase]


func _ready() -> void:
	current = self
	
	input_characters.append(spawn_character(load(Paths.CHARACTER_DATA_TEST1), Vector2.ZERO, "a"))
	spawn_character(load(Paths.CHARACTER_DATA_TEST2), Vector2.ZERO, "a")
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		var pos = get_global_mouse_position()

		for character in input_characters:
			if character.auto_attack_target:
				character.auto_attack_target = null
			
			character.move_to(pos)
	
	if event.is_action_pressed("auto_attack_target_set"):
		var target: CharacterBase

		var point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()

		point_query.position = get_global_mouse_position()
		point_query.collide_with_areas = true

		var result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(
			point_query
		)

		for hit in result:
			var collider = hit["collider"]

			if collider is CharacterBase:
				target = collider
				break

		if target:
			for character in input_characters:
				if target != character:
					character.auto_attack_target = target
	
	if event.is_action_pressed("stop"):
		for character in input_characters:
			character.stop()
	
	if event.is_action_pressed("skill_q"):
		for character in input_characters:
			character.character_logic.cast_q()
	
	if event.is_action_pressed("skill_w"):
		for character in input_characters:
			character.character_logic.cast_w()
	
	if event.is_action_pressed("skill_e"):
		for character in input_characters:
			character.character_logic.cast_e()
	
	if event.is_action_pressed("skill_r"):
		for character in input_characters:
			character.character_logic.cast_r()


func spawn_character(
		character_data: CharacterData,
		character_position: Vector2,
		group_name: String
	) -> CharacterBase:
	
	var character_base = load(Paths.CHARACTER_BASE).instantiate()
	
	character_base.character_data = character_data
	
	character_base.name = character_data.character_name
	character_base.position = character_position
	
	character_base.add_to_group(group_name)
	
	$Characters.add_child(character_base)
	
	return character_base


func spawn_projectile(
	damage_info: DamageInfo,
	speed: float,
	radius: float
) -> Projectile:
	
	var projectile: Projectile = load(Paths.PROJECTILE).instantiate()
	
	projectile.damage_info = damage_info
	projectile.projectile_speed = speed
	projectile.projectile_radius = radius
	
	$Projectiles.add_child(projectile)
	
	return projectile
