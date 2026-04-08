extends Node

const MAIN_SCENE_PATH := "res://scenes/main/main.tscn"

func _ready() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)
