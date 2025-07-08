extends Node

# Controlador de escenas multijugador
class_name MultiplayerScene

# Lista de microjuegos disponibles
var available_microgames: Array = [
	"res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn",
	"res://Microjuegos/Emily/3_Apunta y dispara/Escena/main.tscn",
	"res://Microjuegos/Emily/5_Encuentra al impostor/Escena/5_encuentra_impostor.tscn",
	"res://Microjuegos/Cuello/16_Tecla gatuna/Escena/Tecla gatuna (1).tscn",
	"res://Microjuegos/Cuello/18_Gato equilibrio/Escena/Gato equilibrio (2).tscn",
	"res://Microjuegos/Cuello/19_  Baile rítmico/Escena/Baile rítmico (5).tscn"
]

# Referencias a sistemas
var multiplayer_game: MultiplayerGame
var network_manager: Node
var chat_manager: Node

# Estado actual
var current_microgame_index: int = 0
var is_host: bool = false

func _ready():
	print("🎬 MultiplayerScene iniciado")
	
	# Obtener referencias a sistemas
	network_manager = get_node("/root/NetworkManager")
	multiplayer_game = get_node_or_null("MultiplayerGame")
	
	if not multiplayer_game:
		multiplayer_game = preload("res://online/core/MultiplayerGame.gd").new()
		add_child(multiplayer_game)
	
	# Conectar señales
	if network_manager:
		network_manager.match_started.connect(_on_match_started)
		network_manager.game_data_received.connect(_on_game_data_received)
		network_manager.match_ready.connect(_on_match_ready)
	
	if multiplayer_game:
		multiplayer_game.game_state_changed.connect(_on_game_state_changed)

func _on_match_started(data: Dictionary):
	print("🎮 Partida iniciada - Cargando primer microjuego")
	start_random_microgame()

func _on_match_ready(data: Dictionary):
	print("🎯 Jugadores listos para comenzar")
	
	# Si somos el host, enviamos el microjuego seleccionado
	if is_host:
		select_and_send_microgame()

func start_random_microgame():
	if available_microgames.size() == 0:
		print("❌ No hay microjuegos disponibles")
		return
	
	# Seleccionar un microjuego aleatorio
	var random_index = randi() % available_microgames.size()
	var selected_microgame = available_microgames[random_index]
	
	print("🎲 Microjuego seleccionado: ", selected_microgame)
	
	# Informar al oponente sobre el microjuego seleccionado
	if network_manager:
		var game_data = {
			"event": "microgame_selected",
			"microgame": selected_microgame,
			"index": random_index
		}
		network_manager.send_game_data(game_data)
	
	# Iniciar el microjuego
	if multiplayer_game:
		multiplayer_game.start_microgame(selected_microgame)

func select_and_send_microgame():
	var selected_microgame = get_next_microgame()
	
	if network_manager:
		var game_data = {
			"event": "microgame_selected",
			"microgame": selected_microgame,
			"index": current_microgame_index
		}
		network_manager.send_game_data(game_data)
	
	# Iniciar el microjuego
	if multiplayer_game:
		multiplayer_game.start_microgame(selected_microgame)

func get_next_microgame() -> String:
	if available_microgames.size() == 0:
		return ""
	
	var microgame = available_microgames[current_microgame_index]
	current_microgame_index = (current_microgame_index + 1) % available_microgames.size()
	
	return microgame

func _on_game_data_received(data: Dictionary):
	print("📊 Datos recibidos: ", data)
	
	var event = data.get("event", "")
	
	match event:
		"microgame_selected":
			var microgame_path = data.get("microgame", "")
			if microgame_path != "":
				print("🎮 Oponente seleccionó microjuego: ", microgame_path)
				
				# Si no somos el host, iniciamos el mismo microjuego
				if not is_host and multiplayer_game:
					multiplayer_game.start_microgame(microgame_path)
		
		"microgame_result":
			var success = data.get("success", false)
			var microgame = data.get("microgame", "")
			print("🏆 Resultado del oponente - Microjuego: ", microgame, " Éxito: ", success)

func _on_game_state_changed(state: String):
	print("🎮 Estado del juego cambiado a: ", state)
	
	match state:
		"RESULTS":
			show_results()
		"FINISHED":
			return_to_lobby()

func show_results():
	print("🏆 Mostrando resultados de la partida")
	
	# Cambiar a la escena de resultados
	var results_scene = load("res://online/ui/escena_resultado.tscn")
	if results_scene:
		get_tree().change_scene_to_packed(results_scene)
	else:
		print("❌ No se pudo cargar la escena de resultados")

func return_to_lobby():
	print("🏠 Regresando al lobby")
	
	# Cambiar a la escena del lobby/menú principal
	var main_menu = load("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
	if main_menu:
		get_tree().change_scene_to_packed(main_menu)
	else:
		print("❌ No se pudo cargar la escena del menú principal")

func set_host(host: bool):
	is_host = host
	print("🎯 Establecido como host: ", is_host)

func get_available_microgames() -> Array:
	return available_microgames.duplicate()

func add_microgame(microgame_path: String):
	if microgame_path not in available_microgames:
		available_microgames.append(microgame_path)
		print("➕ Microjuego agregado: ", microgame_path)

func remove_microgame(microgame_path: String):
	var index = available_microgames.find(microgame_path)
	if index >= 0:
		available_microgames.remove_at(index)
		print("➖ Microjuego removido: ", microgame_path)

func get_current_microgame_index() -> int:
	return current_microgame_index

func reset_microgame_index():
	current_microgame_index = 0
	print("🔄 Índice de microjuegos reiniciado")