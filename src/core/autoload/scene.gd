extends Node


var container: Node
var current_scene: Node
var target_scene_path: String


func initialization(scene_container: Node):
	container = scene_container
	

func change(path: String) -> void:
	
	var packed: PackedScene = load(path)

	if current_scene:
		current_scene.queue_free()
		current_scene = null

	var scene: Node = packed.instantiate()

	container.add_child(scene)

	current_scene = scene
