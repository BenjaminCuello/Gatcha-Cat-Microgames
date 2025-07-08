extends Node

# WebSocket peer
var websocket: WebSocketPeer
var server_url = "ws://ucn-game-server.martux.cl:4010/?gameId=E&playerName=gATO"

# Estado de conexión
var is_connected = false
var connection_attempts = 0
var max_reconnect_attempts = 5

# Datos del jugador y partida
var player_data = {}
var current_match_id = ""
var match_status = ""
var game_state = "LOBBY"  # LOBBY, MAP_SELECTION, IN_GAME, POST_GAME

# Señales para comunicación entre escenas
signal player_connected(data)
signal match_request_received(player_name, player_id, match_id)
signal match_accepted(data)
signal match_ready(data)
signal match_started(data)
signal game_data_received(data)
signal game_ended(data)
signal rematch_requested(data)
signal match_quit(data)  # Se emite cuando el OPONENTE salió (close-match recibido)
signal player_list_updated(players)
signal chat_message_received(sender, message)
signal private_message_received(sender, player_id, message)  # ← NUEVA SEÑAL
signal message_received(data)

func _ready():
	print("🔗 WebSocketManager Singleton iniciado")
	websocket = WebSocketPeer.new()
	connect_to_server()

func _process(_delta):
	if not websocket:
		return
		
	websocket.poll()
	var state = websocket.get_ready_state()
	
	match state:
		WebSocketPeer.STATE_CONNECTING:
			pass
			
		WebSocketPeer.STATE_OPEN:
			if not is_connected:
				is_connected = true
				connection_attempts = 0
				print("✅ Conectado al servidor WebSocket!")
				on_connection_established()
			
			while websocket.get_available_packet_count():
				var packet = websocket.get_packet()
				var message = packet.get_string_from_utf8()
				handle_message(message)
				
		WebSocketPeer.STATE_CLOSING:
			print("🔄 Cerrando conexión...")
			
		WebSocketPeer.STATE_CLOSED:
			if is_connected:
				print("❌ Conexión perdida")
				is_connected = false
				attempt_reconnection()

func connect_to_server():
	print("🔗 Conectando al servidor WebSocket...")
	var error = websocket.connect_to_url(server_url)
	
	if error != OK:
		print("❌ Error al conectar: ", error)
		attempt_reconnection()
	else:
		print("⏳ Conexión iniciada...")

func on_connection_established():
	var login = {
		"event": "login",
		"data": {
			"gameKey": "TXWGJ7"
		}
	}
	send_message(login)

func send_message(data: Dictionary):
	if not is_connected:
		print("⚠️ No conectado. No se puede enviar mensaje.")
		return false

	var json_string = JSON.stringify(data)
	var error = websocket.send_text(json_string)
	
	if error != OK:
		print("❌ Error al enviar mensaje: ", error)
		return false
	
	return true

func handle_message(message: String):
	var json = JSON.new()
	var parse_result = json.parse(message)
	
	if parse_result != OK:
		print("❌ Error al parsear mensaje JSON")
		return
	
	var data = json.data
	
	if not data.has("event"):
		print("⚠️ Mensaje sin evento")
		return
	
	# Emitir señal para interceptar todos los mensajes
	emit_signal("message_received", data)
	
	var event = data.get("event", "")
	var status = data.get("status", "")
	var msg = data.get("msg", "")
	
	print("📨 Evento: ", event, " | Estado: ", status)
	
	# Manejar errores específicos de send-game-data
	if event == "send-game-data" and status == "ERROR":
		print("⚠️ Error en send-game-data: ", msg)
		var player_status = data.get("data", {}).get("playerStatus", "")
		if player_status == "AVAILABLE":
			print("🔄 Jugador no está en partida multiplayer")
	
	match event:
		"login":
			handle_login(data.get("data", {}))
		"public-message":
			handle_public_message(data.get("data", {}))
		"private-message":  # ← NUEVO EVENTO
			handle_private_message(data.get("data", {}))
		"online-players":
			handle_online_players(data.get("data", []))
		"match-request-received":
			handle_match_request_received(data.get("data", {}), msg)
		"match-accepted":
			handle_match_accepted(data.get("data", {}))
		"players-ready":
			handle_players_ready(data.get("data", {}))
		"match-start":
			handle_match_start(data.get("data", {}))
		"receive-game-data":
			handle_receive_game_data(data.get("data", {}))
		"game-ended":
			handle_game_ended(data.get("data", {}))
		"rematch-request":
			handle_rematch_request()
		"close-match":
			handle_close_match()
		"quit-match":
			handle_quit_match_response()
		"error":
			handle_error(data.get("data", {}))
		
func handle_login(data: Dictionary):
	player_data = data
	print("✅ Login exitoso - ID: ", data.get("id", ""))
	emit_signal("player_connected", data)

func handle_public_message(data: Dictionary):
	var sender = data.get("playerName", "")
	var message = data.get("playerMsg", "")
	emit_signal("chat_message_received", sender, message)

# ← NUEVA FUNCIÓN PARA MANEJAR MENSAJES PRIVADOS
func handle_private_message(data: Dictionary):
	var sender = data.get("playerName", "")
	var player_id = data.get("playerId", "")
	var message = data.get("playerMsg", "")
	print("💬 Mensaje privado de: ", sender, " - ", message)
	emit_signal("private_message_received", sender, player_id, message)

func handle_online_players(players: Array):
	emit_signal("player_list_updated", players)

func handle_match_request_received(data: Dictionary, message: String):
	var player_id = data.get("playerId", "")
	var match_id = data.get("matchId", "")
	var player_name = extract_player_name_from_message(message)
	
	current_match_id = match_id
	
	print("⚔️ Solicitud de partida de: ", player_name)
	emit_signal("match_request_received", player_name, player_id, match_id)

func handle_match_accepted(data: Dictionary):
	current_match_id = data.get("matchId", "")
	match_status = data.get("matchStatus", "")
	
	print("✅ Partida aceptada - Estado: ", match_status)
	emit_signal("match_accepted", data)

func handle_players_ready(data: Dictionary):
	print("🎯 Jugadores listos (puede ser revancha)")
	match_status = "WAITING_SYNC"
	emit_signal("match_ready", data)

func handle_match_start(data: Dictionary):
	print("🎮 PARTIDA INICIADA")
	current_match_id = data.get("matchId", current_match_id)
	game_state = "IN_GAME"
	
	emit_signal("match_started", data)

func handle_receive_game_data(data: Dictionary):
	print("📊 Datos de juego recibidos")
	emit_signal("game_data_received", data)

func handle_game_ended(data: Dictionary):
	print("🏁 Partida terminada")
	game_state = "POST_GAME"
	emit_signal("game_ended", data)

func handle_rematch_request():
	print("🔄 Solicitud de revancha recibida del oponente")
	emit_signal("rematch_requested")

func handle_close_match():
	print("🚪 CLOSE-MATCH: El oponente salió de la partida")
	print("📝 Cualquier solicitud de revancha ha sido cancelada automáticamente")
	emit_signal("match_quit")

func handle_quit_match_response():
	print("✅ QUIT-MATCH: Confirmación de que salí de la partida")
	emit_signal("match_quit")
	
func handle_error(data: Dictionary):
	print("❌ Error del servidor: ", data.get("message", ""))

func extract_player_name_from_message(message: String) -> String:
	var parts = message.split("'")
	if parts.size() >= 2:
		return parts[1]
	return "Jugador desconocido"

# ===== FUNCIONES PÚBLICAS PARA LAS ESCENAS =====

func send_public_message(text: String):
	var message = {
		"event": "send-public-message",
		"data": {"message": text}
	}
	send_message(message)

# ← NUEVA FUNCIÓN PARA ENVIAR MENSAJES PRIVADOS
func send_private_message(player_id: String, text: String):
	var message = {
		"event": "send-private-message",
		"data": {
			"playerId": player_id,
			"message": text
		}
	}
	send_message(message)

func send_match_request(player_id: String):
	var request = {
		"event": "send-match-request",
		"data": {"playerId": player_id}
	}
	send_message(request)

func accept_match():
	var response = {"event": "accept-match"}
	send_message(response)

func reject_match():
	var response = {"event": "reject-match"}
	send_message(response)

func connect_match():
	var connect_msg = {"event": "connect-match"}
	send_message(connect_msg)

func ping_match():
	var ping_msg = {"event": "ping-match"}
	send_message(ping_msg)

func send_game_data(game_data: Dictionary):
	var message = {
		"event": "send-game-data",
		"data": game_data
	}
	send_message(message)

func finish_game(result_data: Dictionary = {}):
	var message = {
		"event": "finish-game",
		"data": result_data
	}
	game_state = "POST_GAME"
	send_message(message)

func send_rematch_request():
	var message = {"event": "send-rematch-request"}
	send_message(message)

func quit_match():
	print("🚪 Enviando QUIT-MATCH...")
	var message = {"event": "quit-match"}
	send_message(message)

func request_online_players():
	var request = {"event": "online-players"}
	send_message(request)

func attempt_reconnection():
	if connection_attempts >= max_reconnect_attempts:
		print("🚫 Máximo de intentos de reconexión alcanzado")
		return
	
	connection_attempts += 1
	print("🔄 Intento de reconexión ", connection_attempts, "/", max_reconnect_attempts)
	
	await get_tree().create_timer(2.0).timeout
	connect_to_server()

func disconnect_from_server():
	if is_connected:
		var message = {
			"event": "player_disconnect",
			"data": {"player_id": player_data.get("id", "")}
		}
		send_message(message)
		websocket.close()
		is_connected = false

func change_player_name(name: String):
	var message = {"event": "change-name",
	"data": {
		"name": name
		}
	}
	send_message(message)

# Getters
func get_player_data() -> Dictionary:
	return player_data

func get_current_match_id() -> String:
	return current_match_id

func get_game_state() -> String:
	return game_state

func set_game_state(state: String):
	game_state = state
	print("🎮 Estado del juego cambiado a: ", state)

func is_in_match() -> bool:
	return current_match_id != ""

func _exit_tree():
	disconnect_from_server()
