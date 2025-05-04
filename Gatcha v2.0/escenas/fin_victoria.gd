extends Control

func _on_BotonMenu_pressed():
	get_tree().change_scene_to_file("res://escenas/menu_principal.tscn")

func _on_BotonSalir_pressed():
	get_tree().quit()
