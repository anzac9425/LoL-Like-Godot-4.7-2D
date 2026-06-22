extends Node2D
class_name Ingame


static var current: Ingame

var input_characters: Array[CharacterBase]

var player


func _ready() -> void:
	current = self
	
	$Camera2D.zoom = Vector2(0.625 , 0.625)
	
	player = spawn_character(load(Paths.CHARACTER_DATA_ASHE), Vector2(3000, 0), "character", "team1")
	input_characters.append(player)
	
	player.add_rune(load(Paths.RUNE_DATA_LETHAL_TEMPO))
	player.add_item(load(Paths.ITEM_DATA_BERSERKERS_GREAVES))
	player.add_item(load(Paths.ITEM_DATA_INFINITY_EDGE))
	player.add_item(load(Paths.ITEM_DATA_RUNAANS_HURRICANE))
	player.add_item(load(Paths.ITEM_DATA_HEXOPTICS_C44))
	player.add_item(load(Paths.ITEM_DATA_PHANTOM_DANCER))
	player.add_item(load(Paths.ITEM_DATA_BLADE_OF_THE_RUINED_KING))
	player.add_item(load(Paths.ITEM_DATA_LORD_DOMINIKS_REGARDS))
	player.add_item(load(Paths.ITEM_DATA_GUARDIAN_ANGEL))
	
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(-1000, 0), "character", "team2")
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(1000, 0), "characster", "team2")
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(-1000, 1000), "character", "team2")
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(-1000, -1000), "character", "team2")
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(1000, 1000), "character", "team2")
	spawn_character(load(Paths.CHARACTER_DATA_DARIUS), Vector2(1000, -1000), "character", "team2")
	
	for character: CharacterBase in $Characters.get_children():
		if character != player:
			character.auto_attack_target = player
			character.add_rune(load(Paths.RUNE_DATA_CONQUEROR))
			character.add_item(load(Paths.ITEM_DATA_TRINITY_FORCE))
			character.add_item(load(Paths.ITEM_DATA_SPEAR_OF_SHOJIN))
			character.add_item(load(Paths.ITEM_DATA_BLACK_CLEAVER))
			character.add_item(load(Paths.ITEM_DATA_SUNDERED_SKY))
			character.add_item(load(Paths.ITEM_DATA_STERAKS_GAGE))
			character.add_item(load(Paths.ITEM_DATA_DEATHS_DANCE))
			character.add_item(load(Paths.ITEM_DATA_OVERLORDS_BLOODMAIL))

func _process(delta: float) -> void:
	$Camera2D.global_position = $Camera2D.global_position.lerp(player.global_position, 1.0 * delta)
	
	if Input.is_action_pressed("zoom_in"):
		$Camera2D.zoom += Vector2.ONE * delta

	if Input.is_action_pressed("zoom_out"):
		$Camera2D.zoom -= Vector2.ONE * delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		var pos = get_global_mouse_position()

		for character in input_characters:
			if character.auto_attack_target:
				character.auto_attack_target = null
			
			character.move_to(pos, true)
	
	if event.is_action_pressed("auto_attack_target_set"):
		var target: CharacterBase = get_target_at_mouse_position()

		if target:
			for character in input_characters:
				if target != character:
					character.auto_attack_target = target
	
	if event.is_action_pressed("stop"):
		for character in input_characters:
			character.stop()
	
	if event.is_action_pressed("skill_q"):
		for character in input_characters:
			character.on_cast(SourceType.Type.SKILL_Q)
	
	if event.is_action_pressed("skill_w"):
		for character in input_characters:
			character.on_cast(SourceType.Type.SKILL_W)
	
	if event.is_action_pressed("skill_e"):
		for character in input_characters:
			character.on_cast(SourceType.Type.SKILL_E)
	
	if event.is_action_pressed("skill_r"):
		for character in input_characters:
			character.on_cast(SourceType.Type.SKILL_R)


func get_target_at_mouse_position() -> CharacterBase:
	var target: CharacterBase

	var point_query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()

	point_query.position = get_global_mouse_position()
	point_query.collide_with_areas = true

	var result: Array[Dictionary] = (
		get_world_2d().direct_space_state.intersect_point(point_query)
	)

	for hit in result:
		var collider = hit["collider"]

		if collider is CharacterBase:
			target = collider
			break

	return target


func spawn_character(
		character_data: CharacterData,
		character_position: Vector2,
		group_name: String,
		team: String
	) -> CharacterBase:
	
	var character_base = load(Paths.CHARACTER_BASE).instantiate()
	
	character_base.character_data = character_data
	
	character_base.name = character_data.character_name
	character_base.position = character_position
	
	character_base.add_to_group(group_name)
	character_base.team = team
	
	$Characters.add_child(character_base)
	
	return character_base


func spawn_projectile(
	damage_info: DamageInfo,
	type: Projectile.Type,
	speed: float,
	radius: float,
	spawn_position: Vector2 = damage_info.attacker.global_position,
	direction: Vector2 = Vector2.ZERO,
	max_distance: float = 0.0,
	pierce: bool = false
) -> Projectile:
	
	var projectile: Projectile = load(Paths.PROJECTILE).instantiate()

	projectile.projectile_type = type

	projectile.damage_info = damage_info
	projectile.projectile_speed = speed
	projectile.projectile_radius = radius

	projectile.spawn_position = spawn_position
	projectile.direction = direction.normalized()

	projectile.max_distance = max_distance
	projectile.pierce = pierce

	$Projectiles.add_child(projectile)

	return projectile


func spawn_area(area: Area) -> Area:
	$Areas.add_child(area)

	return area
