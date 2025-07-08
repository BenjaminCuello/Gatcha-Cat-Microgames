extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

var microjuegos_jugados := []

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	game_logic.game_over.connect(_on_game_over)
	print("MultiplayerScene lista. Jugador contra: ", Global.oponente)
	_iniciar_microjuego()

func _iniciar_microjuego():
	var ruta = _obtener_siguiente_microjuego()
	if ruta == "":
		_on_game_over("Fin de la lista") # O puedes mostrar una pantalla especial si quieres
		return
	if not ResourceLoader.exists(ruta):
		print("Error: Microjuego no encontrado: ", ruta)
		_iniciar_microjuego() # Intenta otro si hay un problema
		return
	var escena_resource = load(ruta)
	if escena_resource == null:
		print("Error: No se pudo cargar: ", ruta)
		_iniciar_microjuego() # Intenta otro si hay un problema
		return
	var escena = escena_resource.instantiate()
	if game_logic.dificultad_extra != "":
		if escena.has_method("aplicar_dificultad"):
			escena.aplicar_dificultad(game_logic.dificultad_extra)
			print("⚠️ Dificultad extra aplicada:", game_logic.dificultad_extra)
		else:
			print("⚠️ El microjuego no implementa aplicar_dificultad()")
		game_logic.dificultad_extra = ""  # Resetear después de aplicar
	# Conectar señales
	if escena.has_signal("finished"):
		escena.finished.connect(_on_microjuego_finished)
	elif escena.has_signal("microjuego_superado"):
		escena.microjuego_superado.connect(_on_microjuego_superado)
		escena.microjuego_fallado.connect(_on_microjuego_fallado)
	add_child(escena)

func _on_microjuego_finished(success: bool):
	if success:
		game_logic.on_microjuego_superado()
	else:
		game_logic.on_microjuego_fallado()
	# Pantalla intermedia antes del siguiente microjuego
	_mostrar_pantalla_intermedia(_iniciar_microjuego)

func _on_microjuego_superado():
	game_logic.on_microjuego_superado()
	_mostrar_pantalla_intermedia(_iniciar_microjuego)

func _on_microjuego_fallado():
	game_logic.on_microjuego_fallado()
	_mostrar_pantalla_intermedia(_iniciar_microjuego)

func _mostrar_pantalla_intermedia(callback: Callable):
	var pantalla = preload("res://EscenasGenerales/Multiplayer/PantallaIntermediaMultijugador.tscn").instantiate()
	add_child(pantalla)
	pantalla.continuar.connect(callback)

func _on_game_over(winner):
	_mostrar_pantalla_resultados(winner, "Puedes mostrar aquí el puntaje o estadísticas.")

func _mostrar_pantalla_resultados(ganador: String, stats_text: String):
	var resultados = preload("res://EscenasGenerales/Multiplayer/ResultadosMultijugador.tscn").instantiate()
	add_child(resultados)
	resultados.mostrar_resultados(ganador, stats_text)

func _obtener_siguiente_microjuego() -> String:
	# Usa la lista centralizada de Juego para el modo multijugador
	var disponibles := []
	for m in Juego.lista_microjuegos:
		if not microjuegos_jugados.has(m):
			disponibles.append(m)
	if disponibles.size() == 0:
		# Si ya jugaste todos, puedes reiniciar (para juego infinito) o terminar
		# microjuegos_jugados.clear()
		return "" # Fin de la lista, termina partida o ciclo completo
	var elegido = disponibles.pick_random()
	microjuegos_jugados.append(elegido)
	return elegido
