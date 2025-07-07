extends Control

func _ready():
	$ReproductorVideo.play()
	$SonidoCinematica.play()

	# Esperar a que termine la cinemática
	await get_tree().create_timer(5.0).timeout
	
	# La cinemática solo se usa en modo historia
	# Después de la cinemática, ir a la pantalla de transición
	get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")
