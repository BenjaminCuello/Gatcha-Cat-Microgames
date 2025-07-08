extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Menú Principal cargado")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_boton_historia_pressed() -> void:
	print("¡Botón HISTORIA presionado!")
	
	# Inicializar modo historia
	Juego.iniciar_modo_historia()
	
	# Ir a la pantalla de transición
	get_tree().change_scene_to_file("res://EscenasGenerales/Cinematicas/CinematicaGatoDurmiendo.tscn")

func _on_boton_infinito_pressed() -> void:
	print("¡Botón MODO INFINITO presionado!")
	
	# Inicializar modo infinito
	Juego.iniciar_modo_infinito()
	
	# Ir a la pantalla de transición
	get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")



func _on_boton_opciones_pressed() -> void:

	print("¡Botón OPCIONES presionado!")

	# 🔧 NUEVO: Cargar el menú de opciones

	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuOpciones.tscn")

func _on_boton_salir_pressed() -> void:
	print("¡Botón SALIR presionado!")
	get_tree().quit()
	

func _on_boton_multijugador_pressed() -> void:
	print("¡Botón MULTIJUGADOR presionado!")
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/Online/user_login.tscn")
