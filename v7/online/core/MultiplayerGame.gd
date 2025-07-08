extends Node

# Lógica principal del juego multijugador
class_name MultiplayerGame

# Señales para comunicación con otros sistemas
signal microjuego_superado
signal microjuego_fallado
signal finished(success: bool)
signal player_ready
signal game_state_changed(state: String)

# Estados del juego
enum GameState {
	LOBBY,
	MAP_SELECTION,
	LOADING,
	PLAYING,
	RESULTS,
	FINISHED
}

var current_state: GameState = GameState.LOBBY
var players_ready: Array = []
var current_microgame: String = ""
var game_results: Dictionary = {}

# Referencias a sistemas
var network_manager: Node
var chat_manager: Node
var vida_contador: Node

func _ready():
	print("🎮 MultiplayerGame iniciado")
	
	# Conectar con NetworkManager
	network_manager = get_node("/root/NetworkManager")
	if network_manager:
		network_manager.game_data_received.connect(_on_game_data_received)
		network_manager.match_started.connect(_on_match_started)
		network_manager.game_ended.connect(_on_game_ended)
	
	# Conectar señales locales
	finished.connect(_on_game_finished)

func change_state(new_state: GameState):
	if current_state == new_state:
		return
	
	print("🎮 Estado cambiado de ", GameState.keys()[current_state], " a ", GameState.keys()[new_state])
	current_state = new_state
	emit_signal("game_state_changed", GameState.keys()[new_state])

func start_microgame(microgame_path: String):
	print("🎯 Iniciando microjuego: ", microgame_path)
	current_microgame = microgame_path
	change_state(GameState.PLAYING)
	
	# Cargar el microjuego
	var microgame_scene = load(microgame_path)
	if microgame_scene:
		var microgame_instance = microgame_scene.instantiate()
		
		# Conectar señales del microjuego
		if microgame_instance.has_signal("microjuego_superado"):
			microgame_instance.microjuego_superado.connect(_on_microjuego_superado)
		if microgame_instance.has_signal("microjuego_fallado"):
			microgame_instance.microjuego_fallado.connect(_on_microjuego_fallado)
		if microgame_instance.has_signal("finished"):
			microgame_instance.finished.connect(_on_microjuego_finished)
		
		# Cambiar a la escena del microjuego
		get_tree().current_scene.add_child(microgame_instance)
	else:
		print("❌ Error: No se pudo cargar el microjuego: ", microgame_path)

func _on_microjuego_superado():
	print("✅ Microjuego superado")
	emit_signal("microjuego_superado")
	send_game_result(true)

func _on_microjuego_fallado():
	print("❌ Microjuego fallado")
	emit_signal("microjuego_fallado")
	send_game_result(false)

func _on_microjuego_finished(success: bool):
	print("🏁 Microjuego terminado - Éxito: ", success)
	emit_signal("finished", success)
	send_game_result(success)

func send_game_result(success: bool):
	if network_manager:
		var result_data = {
			"microgame": current_microgame,
			"success": success,
			"timestamp": Time.get_unix_time_from_system()
		}
		network_manager.send_game_data(result_data)

func _on_game_data_received(data: Dictionary):
	print("📊 Datos de juego recibidos del oponente: ", data)
	
	# Almacenar resultados del oponente
	if data.has("success"):
		game_results["opponent"] = data.get("success", false)
		game_results["opponent_microgame"] = data.get("microgame", "")

func _on_match_started(data: Dictionary):
	print("🎮 Partida multijugador iniciada")
	change_state(GameState.MAP_SELECTION)

func _on_game_ended(data: Dictionary):
	print("🏁 Partida terminada")
	change_state(GameState.RESULTS)
	
	# Mostrar resultados
	show_results(data)

func _on_game_finished(success: bool):
	print("🏆 Juego terminado - Resultado: ", success)
	change_state(GameState.FINISHED)

func show_results(data: Dictionary):
	# Cambiar a la escena de resultados
	var results_scene = load("res://online/ui/escena_resultado.tscn")
	if results_scene:
		get_tree().change_scene_to_packed(results_scene)
	else:
		print("❌ No se pudo cargar la escena de resultados")

func get_current_state() -> GameState:
	return current_state

func is_playing() -> bool:
	return current_state == GameState.PLAYING

func reset_game():
	current_state = GameState.LOBBY
	players_ready.clear()
	current_microgame = ""
	game_results.clear()
	print("🔄 Juego reiniciado")