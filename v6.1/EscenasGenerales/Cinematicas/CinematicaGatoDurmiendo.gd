extends Control

func _ready():
	$ReproductorVideo.play()
	$SonidoCinematica.play()

	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")
