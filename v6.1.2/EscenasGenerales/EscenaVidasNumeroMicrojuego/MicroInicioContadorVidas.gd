extends Control

func _ready():
	$MusicaInicio.play()
	
	# Mostrar información según el modo de juego
	mostrar_info_modo()
	
	# Mostrar vidas con corazones
	var label_vidas = $ContenedorInfo/LabelVidas
	if label_vidas:
		var corazones = ""
		for i in range(Juego.vidas):
			corazones += "❤"
		label_vidas.text = "Vidas: " + corazones
	else:
		print("❌ NO se encontró el nodo LabelVidas")

	# Iniciar cuenta regresiva
	$TimerTransicion.start(2.0)

func mostrar_info_modo():
	var label_micro = $ContenedorInfo/LabelMicrojuego
	if not label_micro:
		print("❌ NO se encontró el nodo LabelMicrojuego")
		return
	
	# Obtener información del estado actual
	var info = Juego.obtener_info_estado()
	
	# Mostrar información según el modo
	match Juego.modo_actual:
		Juego.ModoJuego.HISTORIA:
			label_micro.text = "Microjuego " + str(info.microjuego_actual + 1) + "/" + str(info.total_microjuegos)
		Juego.ModoJuego.INFINITO:
			# 🔧 CAMBIO: Mostrar contador continuo de microjuegos
			# Calcular el número total de microjuegos jugados
			var microjuegos_totales_jugados = (Juego.ciclos_completados * info.total_microjuegos) + info.microjuegos_jugados_en_ciclo + 1
			
			label_micro.text = "Microjuego " + str(microjuegos_totales_jugados)
			
			# Debug info
			print("🔍 Mostrando info modo infinito:")
			print("  - Ciclos completados: ", Juego.ciclos_completados)
			print("  - Microjuegos jugados en ciclo actual: ", info.microjuegos_jugados_en_ciclo)
			print("  - Total microjuegos por ciclo: ", info.total_microjuegos)
			print("  - Número de microjuego mostrado: ", microjuegos_totales_jugados)

func _on_TimerTransicion_timeout():
	# Verificar fin del juego por vidas
	if Juego.vidas <= 0:
		get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaDerrotaJuego.tscn")
		return

	# Verificar si el juego debe continuar según el modo
	if not Juego.debe_continuar():
		# En modo historia, si llegamos aquí es porque se completaron todos los microjuegos
		if Juego.modo_actual == Juego.ModoJuego.HISTORIA:
			get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaVictoriaJuego.tscn")
		else:
			# En modo infinito, esto no debería pasar (es infinito)
			print("Error: El modo infinito no debería terminar aquí")
		return

	# Obtener el siguiente microjuego según el modo
	var siguiente_microjuego = Juego.obtener_siguiente_microjuego()
	
	if siguiente_microjuego == "":
		# Esto significa que no hay más microjuegos (solo debería pasar en modo historia)
		if Juego.modo_actual == Juego.ModoJuego.HISTORIA:
			get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaVictoriaJuego.tscn")
		else:
			print("Error: No se pudo obtener el siguiente microjuego en modo infinito")
		return

	# Cargar el microjuego usando el nuevo sistema
	var escena_controlador = load("res://EscenasGenerales/Controladores/ControladorMicrojuegoPorSistema.tscn").instantiate()
	escena_controlador.escena_microjuego = load(siguiente_microjuego)
	get_tree().root.add_child(escena_controlador)
	get_tree().current_scene.queue_free()
