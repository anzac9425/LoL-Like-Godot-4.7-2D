extends Node2D


var input_characters: Array[CharacterBase]


func _ready() -> void:
	input_characters.append(character_spawn(load(Paths.CHARACTER_DATA_TEST1), Vector2.ZERO, "a"))
	character_spawn(load(Paths.CHARACTER_DATA_TEST2), Vector2.ZERO, "a")
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move"):
		var pos = get_global_mouse_position()

		for character in input_characters:
			character.move_to(pos)


func character_spawn(
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
