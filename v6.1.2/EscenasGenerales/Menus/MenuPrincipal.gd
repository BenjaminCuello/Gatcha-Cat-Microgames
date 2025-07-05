extends Control

func _ready():
	# Esto asegura que se pueda salir con ESC solo en modo prueba
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Vidas actuales:", Juego.vidas)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()  # Salir del juego al presionar ESC

func _on_boton_historia_pressed() -> void:
	print("¡Botón HISTORIA presionado!")

	# Reiniciar vidas y progreso
	Juego.reiniciar()

	# Ir a la cinemática
	get_tree().change_scene_to_file("res://EscenasGenerales/Cinematicas/CinematicaGatoDurmiendo.tscn")


func _on_boton_infinito_pressed() -> void:
	print("¡Botón MODO INFINITO presionado!")
	# Aquí más adelante pondrás: get_tree().change_scene_to_file("...")

func _on_boton_multijugador_pressed() -> void:
	print("¡Botón MULTIJUGADOR presionado!")
	# Aquí más adelante pondrás: get_tree().change_scene_to_file("...")

func _on_boton_opciones_pressed() -> void:
	print("¡Botón OPCIONES presionado!")
	# Aquí más adelante pondrás: get_tree().change_scene_to_file("...")

func _on_boton_salir_pressed() -> void:
	print("¡Botón SALIR presionado!")
	get_tree().quit()
