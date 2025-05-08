extends Control

func _ready():
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://escenas/micro_inicio.tscn")
