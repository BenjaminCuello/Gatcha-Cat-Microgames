extends Node

# Referencias a sistemas locales
@onready var chat_system = get_node_or_null("../ChatSystem")
@onready var player_list_system = get_node_or_null("../PlayerListSystem")

func _ready():
	print("🔗 OnlineController iniciado")
	connect_network_signals()

func connect_network_signals():
	if not NetworkManager:
		print("❌ NetworkManager no disponible")
		return
	
	# Conectar todas las señales del NetworkManager
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.match_request_received.connect(_on_match_request_received)
	NetworkManager.match_accepted.connect(_on_match_accepted)
	NetworkManager.match_ready.connect(_on_match_ready)
	NetworkManager.match_started.connect(_on_match_started)
	NetworkManager.rematch_requested.connect(_on_rematch_request)
	NetworkManager.match_quit.connect(_on_match_quit)
	NetworkManager.player_list_updated.connect(_on_player_list_updated)
	NetworkManager.game_ended.connect(_on_game_ended)
	NetworkManager.connection_status_changed.connect(_on_connection_status_changed)
	
	print("✅ Señales del NetworkManager conectadas")

# Event handlers
func _on_player_connected(data: Dictionary):
	print("✅ Jugador conectado: ", data.get("name", ""))
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🟢 Conectado como: " + data.get("name", ""))
	
	if player_list_system and player_list_system.has_method("set_my_player_data"):
		player_list_system.set_my_player_data(data)

func _on_match_request_received(player_name: String, player_id: String, match_id: String):
	print("⚔️ Solicitud de partida recibida de: ", player_name)
	
	if player_list_system and player_list_system.has_method("show_match_request"):
		player_list_system.show_match_request(player_name, player_id, match_id)
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("⚔️ " + player_name + " quiere jugar contigo")

func _on_match_accepted(data: Dictionary):
	print("✅ Partida aceptada")
	
	if player_list_system and player_list_system.has_method("connect_match"):
		player_list_system.connect_match()
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("✅ Partida aceptada. Preparándose...")

func _on_match_ready(data: Dictionary):
	print("🎯 Jugadores listos")
	NetworkManager.ping_match()
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🎯 Todos los jugadores están listos")

func _on_match_started(data: Dictionary):
	print("🎮 Partida iniciada, cargando selección de mapas...")
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🎮 ¡Partida iniciada!")
	
	# Cambiar a selección de mapas
	var map_selection_scene = load("res://GUI/Escenas/map_select_multijugador.tscn")
	if map_selection_scene:
		get_tree().change_scene_to_packed(map_selection_scene)
	else:
		print("❌ Error: No se pudo cargar map_select_multijugador.tscn")

func _on_rematch_request():
	print("🔄 Solicitud de revancha del oponente")
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🔄 El oponente quiere la revancha")

func _on_match_quit():
	print("🚪 El oponente salió de la partida")
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🚪 El oponente salió de la partida")
	
	# Volver al menú principal
	var main_menu = load("res://Escenas/main_menu.tscn")
	if main_menu:
		get_tree().change_scene_to_packed(main_menu)
	else:
		print("❌ No se encontró la escena de menú")

func _on_player_list_updated(players: Array):
	print("👥 Lista de jugadores actualizada: ", players.size(), " jugadores")
	
	if player_list_system and player_list_system.has_method("update_player_list"):
		player_list_system.update_player_list(players)

func _on_game_ended(data: Dictionary):
	print("🏁 Partida terminada")
	
	if chat_system and chat_system.has_method("add_system_message"):
		chat_system.add_system_message("🏁 Partida terminada")
	
	# Cargar pantalla de derrota/victoria
	var loss_screen = load("res://GUI/Escenas/loss_escene.tscn")
	if loss_screen:
		get_tree().change_scene_to_packed(loss_screen)
	else:
		print("❌ No se encontró la escena de derrota")

func _on_connection_status_changed(connected: bool):
	if connected:
		print("🟢 Estado de conexión: Conectado")
	else:
		print("🔴 Estado de conexión: Desconectado")

# Funciones de conveniencia para mantener compatibilidad
func send_message(data: Dictionary) -> bool:
	return NetworkManager.send_message(data)

func send_public_message(text: String) -> bool:
	return NetworkManager.send_public_message(text)

func request_online_players() -> bool:
	return NetworkManager.request_online_players()

func send_match_request(player_id: String) -> bool:
	return NetworkManager.send_match_request(player_id)

func accept_match() -> bool:
	return NetworkManager.accept_match()

func reject_match() -> bool:
	return NetworkManager.reject_match()
