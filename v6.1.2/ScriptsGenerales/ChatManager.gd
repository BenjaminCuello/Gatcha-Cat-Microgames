extends Control

var invitacion_recibida = ""
var match_id = ""
var oponente = ""
var mi_nombre := Global.username
var jugadores_conectados := {} # ID → nombre

var _host := "ws://ucn-game-server.martux.cl:4010/?gameId=E&playerName=%s" % mi_nombre
@onready var _client: WebSocketClient = $WebSocketClient

@onready var chat_display: TextEdit = $VBoxContainer/MainPanel/ChatDisplay
@onready var player_list: ItemList = $VBoxContainer/MainPanel/UserPanel/UserList
@onready var input_message: LineEdit = $VBoxContainer/Commands/InputMessage
@onready var send_button: Button = $VBoxContainer/Commands/SendButton

func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	_sendToChatDisplay("Client disconnected [%d]: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_web_socket_client_connected_to_server():
	_sendToChatDisplay("Conexión establecida. Enviando login...")
	var login_payload = {"event":"login","data":{"gameKey":"TXWGJ7"}}
	_client.send(JSON.stringify(login_payload))
	_sendGetUserListEvent()

func _on_web_socket_client_message_received(message: String):
	var parse := JSON.new()
	if parse.parse(message) != OK:
		_sendToChatDisplay("[Error JSON] %s" % message)
		return
	var resp = parse.get_data()
	print("Mensaje recibido:", resp)
	match resp.get("event", ""):
		"connected-to-server":
			_sendToChatDisplay("You are connected to the server!")
			_sendGetUserListEvent()

		"get-connected-players":
			# Servidor envía lista completa de jugadores actuales
			var list_data = resp.get("data", resp)
			_updateUserList(list_data)

		"player-connected":
			var id = _extract_id(resp)
			var name = _extract_name(resp)
			_addUserToList(name, id)

		"player-disconnected":
			var id = _extract_id(resp)
			_removeUserById(id)

		"public-message":
			var sender = _extract_name(resp)
			var label = "Yo" if sender == mi_nombre else sender
			_sendToChatDisplay("%s: %s" % [label, _extract_data(resp, "playerMsg")])

		"private-message":
			var sender = _extract_name(resp)
			var label = "Yo" if sender == mi_nombre else sender
			_sendToChatDisplay("(Privado de %s): %s" % [label, _extract_data(resp, "message")], true)

		"match-request-received":
			invitacion_recibida = _extract_name(resp)
			_sendToChatDisplay("%s quiere jugar contigo!" % invitacion_recibida)
			$VBoxContainer/AcceptButton.visible = true
			$VBoxContainer/RejectButton.visible = true

		"match-start":
			var data = resp.get("data", {})
			oponente = data.get("opponent", {}).get("playerName", "")
			match_id = data.get("matchId", "")
			Global.oponente = oponente
			Global.match_id = match_id
			_sendToChatDisplay("¡La partida ha comenzado con %s!" % oponente)
			get_tree().change_scene_to_file("res://EscenasGenerales/Multiplayer/MultiplayerScene.tscn")

func _extract_name(resp: Dictionary) -> String:
	var d = resp.get("data", {})
	if typeof(d) == TYPE_DICTIONARY:
		return d.get("playerName", d.get("name", "¿Desconocido?"))
	return "¿Desconocido?"

func _extract_id(resp: Dictionary) -> String:
	var d = resp.get("data", {})
	return d.get("playerId", "") if typeof(d) == TYPE_DICTIONARY else ""

func _extract_data(resp: Dictionary, key: String) -> String:
	var d = resp.get("data", {})
	return str(d.get(key, "")) if typeof(d) == TYPE_DICTIONARY else ""

func _addUserToList(name: String, id: String):
	if name == "" or id == "":
		return
	# Evitar duplicados
	if jugadores_conectados.has(id):
		return
	var display_name = name
	if id == _client.get_unique_id():
		display_name += " (Yo)"
	player_list.add_item(display_name)
	player_list.set_item_metadata(player_list.item_count - 1, id)
	jugadores_conectados[id] = name
	_sendToChatDisplay("Jugador conectado: %s" % display_name)

func _removeUserById(id: String):
	if not jugadores_conectados.has(id):
		return
	for i in range(player_list.get_item_count()):
		if player_list.get_item_metadata(i) == id:
			player_list.remove_item(i)
			break
	jugadores_conectados.erase(id)
	_sendToChatDisplay("Jugador desconectado: %s" % id)

func _on_input_submitted(message: String):
	_handle_send(message)

func _on_send_pressed():
	_handle_send(input_message.text)

func _handle_send(text: String):
	text = text.strip_edges()
	if text == "":
		return
	var sel = player_list.get_selected_items()
	var target = player_list.get_item_metadata(sel[0]) if sel.size() > 0 else ""
	_sendMessage(text, target)
	input_message.text = ""
	input_message.grab_focus()

func _sendMessage(message: String, userId: String = ""):
	var action = "send-private-message" if userId != "" else "send-public-message"
	var payload = {"event": action, "data": {"message": message}}
	if userId != "":
		payload["data"]["playerId"] = userId
	_client.send(JSON.stringify(payload))
	if userId == "":
		_sendToChatDisplay("Yo: %s" % message)
	else:
		var nombre_destinatario = jugadores_conectados.get(userId, userId)
		_sendToChatDisplay("(Privado a %s): %s" % [nombre_destinatario, message], true)

func _sendGetUserListEvent():
	player_list.clear()
	_client.send(JSON.stringify({"event": "get-connected-players"}))

func _updateUserList(data):
	jugadores_conectados.clear()
	player_list.clear()
	if typeof(data) == TYPE_ARRAY:
		for u in data:
			if typeof(u) == TYPE_DICTIONARY:
				var id = u.get("playerId", "")
				var name = u.get("playerName", u.get("name", ""))
				if id != "":
					jugadores_conectados[id] = name
					var display = name + " (Yo)" if name == mi_nombre else name
					player_list.add_item(display)
					player_list.set_item_metadata(player_list.item_count - 1, id)
	else:
		print("_updateUserList: formato de dato inesperado:", data)

func _on_connect_toggled(pressed: bool):
	if not pressed:
		_client.close()
		return
	_sendToChatDisplay("Conectando a %s..." % _host)
	var err = _client.connect_to_url(_host)
	if err != OK:
		_sendToChatDisplay("Error conectando: %s" % _host)

func _sendToChatDisplay(msg: String, is_private: bool = false):
	if is_private:
		chat_display.text += "[Privado] %s\n" % msg
	else:
		chat_display.text += "%s\n" % msg

func _on_invite_button_pressed():
	var sel = player_list.get_selected_items()
	if sel.empty():
		_sendToChatDisplay("Selecciona un jugador primero.")
		return
	var id = player_list.get_item_metadata(sel[0])
	if id == "":
		_sendToChatDisplay("No se pudo obtener el ID del jugador.")
		return
	_client.send(JSON.stringify({"event": "send-match-request", "data": {"playerId": id}}))
	var nombre = jugadores_conectados.get(id, id)
	_sendToChatDisplay("Solicitud enviada a %s" % nombre)

func _on_accept_button_pressed():
	_client.send(JSON.stringify({"event": "accept-match", "data": {"playerName": invitacion_recibida}}))
	_sendToChatDisplay("Aceptaste la partida con %s" % invitacion_recibida)
	_ocultar_botones_match()

func _on_reject_button_pressed():
	_client.send(JSON.stringify({"event": "reject-match", "data": {"playerName": invitacion_recibida}}))
	_sendToChatDisplay("Rechazaste la partida con %s" % invitacion_recibida)
	_ocultar_botones_match()

func _ocultar_botones_match():
	$VBoxContainer/AcceptButton.visible = false
	$VBoxContainer/RejectButton.visible = false
	invitacion_recibida = ""

func _on_boton_volver_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func _on_button_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
