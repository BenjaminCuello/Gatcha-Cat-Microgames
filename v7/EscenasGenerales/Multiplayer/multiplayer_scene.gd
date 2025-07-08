extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

var microjuegos_jugados := []
var vidas := 3

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	game_logic.game_over.connect(_on_game_over)
	vidas = 3
	_iniciar_microjuego()

func _iniciar_microjuego():
	var ruta = _obtener_siguiente_microjuego()
	if ruta == "":
		# Si no hay más microjuegos, es empate si ambos terminaron todo
		_on_game_over("empate", true)
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
		vidas -= 1

	for child in get_children():
		if child != game_logic:
			child.queue_free()

	if vidas > 0:
		_mostrar_pantalla_intermedia(_iniciar_microjuego)
	else:
		var ganador = game_logic.oponente if vidas <= 0 else Global.username
		_on_game_over(ganador, false)

func _on_microjuego_superado():
	game_logic.on_microjuego_superado()
	for child in get_children():
		if child != game_logic:
			child.queue_free()
	_mostrar_pantalla_intermedia(_iniciar_microjuego)

func _on_microjuego_fallado():
	game_logic.on_microjuego_fallado()
	vidas -= 1
	for child in get_children():
		if child != game_logic:
			child.queue_free()
	if vidas > 0:
		_mostrar_pantalla_intermedia(_iniciar_microjuego)
	else:
		var ganador = game_logic.oponente if vidas <= 0 else Global.username
		_on_game_over(ganador, false)

func _mostrar_pantalla_intermedia(callback: Callable):
	var pantalla = preload("res://EscenasGenerales/Multiplayer/PantallaIntermediaMultijugador.tscn").instantiate()
	add_child(pantalla)
	pantalla.continuar.connect(callback)

func _on_game_over(ganador, es_empate := false):
	_mostrar_pantalla_resultados(ganador, "", vidas, es_empate)

func _mostrar_pantalla_resultados(ganador: String, stats_text: String, vidas_restantes: int, es_empate := false):
	var resultados = preload("res://EscenasGenerales/Multiplayer/ResultadosMultijugador.tscn").instantiate()
	add_child(resultados)
	resultados.mostrar_resultados(ganador, stats_text, vidas_restantes, es_empate)

func _obtener_siguiente_microjuego() -> String:
	var disponibles := []
	for m in Juego.lista_microjuegos:
		if not microjuegos_jugados.has(m):
			disponibles.append(m)
	if disponibles.size() == 0:
		return "" # Fin de la lista, empate
	var elegido = disponibles.pick_random()
	microjuegos_jugados.append(elegido)
	return elegido
