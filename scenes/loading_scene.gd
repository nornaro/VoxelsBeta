extends Control

const GAME_SCENE = preload("res://scenes/GameScene.tscn")

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	call_deferred("load_main_scene")

func load_main_scene():
	get_tree().change_scene_to_packed(GAME_SCENE)
