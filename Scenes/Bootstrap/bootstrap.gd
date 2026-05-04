extends Node

const MAIN_SCENE_PATH := "res://Scenes/main.tscn"

func _ready() -> void:
	call_deferred("_change_to_main_scene")


func _change_to_main_scene() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
