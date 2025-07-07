extends Node

# Esta variable se define desde fuera antes de cargar la escena
var escena_microjuego: PackedScene
var instancia_microjuego

func _ready():
	if escena_microjuego:
		instancia_microjuego = escena_microjuego.instantiate()
		
		# LÍNEA AGREGADA: Configurar dificultad antes de agregar el nodo
		if instancia_microjuego.has_method("configurar_dificultad"):
			var nivel_actual = Juego.obtener_nivel_dificultad_actual()
			instancia_microjuego.configurar_dificultad(nivel_actual)
			print("✅ Dificultad configurada: Nivel ", nivel_actual)
		else:
			print("⚠️  El microjuego no tiene método 'configurar_dificultad'")
		
		add_child(instancia_microjuego)

		if instancia_microjuego.has_signal("finished"):
			instancia_microjuego.connect("finished", Callable(self, "_on_microjuego_finished"))
		else:
			print("❌ El microjuego no tiene señal 'finished'")
		
		# Mostrar información del microjuego actual
		mostrar_info_microjuego()

func mostrar_info_microjuego():
	var info = Juego.obtener_info_estado()
	var nivel_dificultad = Juego.obtener_nivel_dificultad_actual()
	
	print("=== MICROJUEGO INICIADO ===")
	print("Modo: ", info.modo)
	print("Nivel de dificultad: ", nivel_dificultad)
	
	if Juego.modo_actual == Juego.ModoJuego.HISTORIA:
		print("Progreso: ", info.progreso)
	else:
		print("Ciclo: ", info.ciclos_completados + 1)
		print("Microjuegos completados: ", info.microjuegos_totales_completados)
	
	print("Vidas: ", info.vidas)
	print("==========================")

func _on_microjuego_finished(success: bool) -> void:
	print("Microjuego terminado. Éxito: ", success)
	
	if not success:
		Juego.vidas -= 1
		print("💥 Perdiste una vida. Vidas restantes:", Juego.vidas)
	else:
		print("✅ Microjuego completado exitosamente!")
	
	# Mostrar estadísticas actualizadas
	Juego.mostrar_estado()
	
	# Esperar un momento antes de continuar
	await get_tree().create_timer(1.0).timeout
	
	# Verificar si el juego debe continuar
	if Juego.debe_continuar():
		# Continuar al siguiente microjuego
		get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/MicroInicioContadorVidas.tscn")
	else:
		# Terminar el juego
		if Juego.vidas <= 0:
			# Perdiste todas las vidas
			get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaDerrotaJuego.tscn")
		elif Juego.modo_actual == Juego.ModoJuego.HISTORIA and Juego.es_historia_completa():
			# Completaste el modo historia
			get_tree().change_scene_to_file("res://EscenasGenerales/EscenaVictoriaDerrota/EscenaVictoriaJuego.tscn")
		else:
			# Caso inesperado
			print("Estado inesperado del juego")
			get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
