extends Node2D


func _ready() -> void:
	Scene.initialization($ActiveScene)
	Scene.change(Paths.START_PATH)
