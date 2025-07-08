extends Control

func _on_BotonMenu_pressed():
	if $MusicaFinal.playing:
		$MusicaFinal.stop()
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func _on_BotonSalir_pressed():
	get_tree().quit()
func _ready():
	$MusicaFinal.play()
