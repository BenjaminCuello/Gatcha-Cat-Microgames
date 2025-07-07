extends Control

func _ready():
	
	$MusicaInicio.play()
	$TimerTransicion.start(1.0)
	
	# Mostrar información según el modo de juego
	if Juego.modo_juego_actual == Juego.ModoJuego.HISTORIA:
		mostrar_info_historia()
	else:
		mostrar_info_infinito()

	# Iniciar cuenta regresiva
	$TimerTransicion.start(2.0)

func mostrar_info_historia():
	# Mostrar número de microjuego
	var label_micro = $ContenedorInfo/LabelMicrojuego
	if label_micro:
		label_micro.text = "Microjuego " + str(Juego.microjuego_actual + 1) + "/" + str(Juego.max_microjuegos)
	else:
		print("❌ NO se encontró el nodo LabelMicrojuego")

	# Mostrar vidas con corazones
	var label_vidas = $ContenedorInfo/LabelVidas
	if label_vidas:
		var corazones = ""
		for i in range(Juego.vidas):
			corazones += "❤"
		label_vidas.text = "Vidas: " + corazones
	else:
		print("❌ NO se encontró el nodo LabelVidas")

func mostrar_info_infinito():
	# Mostrar ronda actual
	var label_micro = $ContenedorInfo/LabelMicrojuego
	if label_micro:
		label_micro.text = "Ronda " + str(Juego.ronda_actual) + " - Microjuego " + str(Juego.microjuego_actual + 1)
	else:
		print("❌ NO se encontró el nodo LabelMicrojuego")

	# Mostrar vidas con corazones
	var label_vidas = $ContenedorInfo/LabelVidas
	if label_vidas:
		var corazones = ""
		for i in range(Juego.vidas):
			corazones += "❤"
		label_vidas.text = "Vidas: " + corazones + " - MODO INFINITO"
	else:
		print("❌ NO se encontró el nodo LabelVidas")

func _on_TimerTransicion_timeout():
	# Verificar fin del juego
	if Juego.vidas <= 0:
		get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaDerrotaJuego.tscn")
		return

	# Verificar si el juego debe terminar (solo en modo historia)
	if Juego.debe_terminar_juego():
		get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaVictoriaJuego.tscn")
		return

	# Aumentar el contador de microjuegos jugados
	Juego.microjuego_actual += 1

	# Obtener microjuego y su nivel de dificultad
	var microjuego_path = Juego.obtener_microjuego_aleatorio()
	var nivel_dificultad = Juego.obtener_nivel_dificultad(microjuego_path)
	
	print("🎮 Cargando microjuego: ", microjuego_path)
	print("🔥 Nivel de dificultad: ", nivel_dificultad)

	# Cargar el microjuego con su nivel de dificultad
	var escena_controlador = load("res://EscenasGenerales/Controladores/ControladorMicrojuegoPorSistema.tscn").instantiate()
	escena_controlador.escena_microjuego = load(microjuego_path)
	escena_controlador.nivel_dificultad = nivel_dificultad
	get_tree().root.add_child(escena_controlador)
	get_tree().current_scene.queue_free()
