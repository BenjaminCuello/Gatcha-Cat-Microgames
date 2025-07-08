extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Menú Principal cargado")
	var boton_online = get_node_or_null("VBoxContainer/BotonOnline")
	if boton_online:
		boton_online.pressed.connect(_on_online_pressed)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

func _on_boton_historia_pressed() -> void:
	print("¡Botón HISTORIA presionado!")
	Juego.iniciar_modo_historia()
	get_tree().change_scene_to_file("res://EscenasGenerales/Cinematicas/CinematicaGatoDurmiendo.tscn")

func _on_boton_infinito_pressed() -> void:
	print("¡Botón MODO INFINITO presionado!")
	Juego.iniciar_modo_infinito()
	get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")

func _on_boton_opciones_pressed() -> void:
	print("¡Botón OPCIONES presionado!")
	# 🔧 NUEVO: Cargar el menú de opciones
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuOpciones.tscn")

func _on_boton_salir_pressed() -> void:
	print("¡Botón SALIR presionado!")
	get_tree().quit()

func _on_boton_chat_pressed() -> void:
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/Online/user_login.tscn")

var boton_online = get_node_or_null("VBoxContainer/BotonOnline")


# Agregar esta función:
func _on_online_pressed():
	print("🌐 Accediendo al modo online...")
	get_tree().change_scene_to_file("res://Online/MenuOnline.tscn")
