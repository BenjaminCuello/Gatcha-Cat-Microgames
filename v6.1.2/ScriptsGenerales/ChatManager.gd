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



func _on_web_socket_client_message_received(message: String):
	var parse := JSON.new()
	var err = parse.parse(message)
	if err != OK:
		_sendToChatDisplay("[Error JSON] %s" % message)
		return
	var resp = parse.get_data()
	print("Mensaje recibido:", message)
	match resp.get("event", ""):
		"connected-to-server":
			_sendToChatDisplay("You are connected to the server!")
			_sendGetUserListEvent()

		"get-connected-players":
			_updateUserList(resp.get("data", []))
		
		"player-status-changed":
			var data = resp.get("data", {})
			var id = data.get("playerId", "")
			var new_status = data.get("playerStatus", "UNKNOWN")
			var player_name = jugadores_conectados.get(id, null)
			if player_name == null:
				print("No se encontró el nombre para ID %s" % id)
				return
			_deleteUserFromList(player_name)
			_addUserToList(player_name, id, new_status)




		"player-connected":
			var data = resp.get("data", {})
			var id = data.get("id", "")
			var player_name = data.get("name", "")
			var status = data.get("status", "UNKNOWN")
			if id != "" and player_name != "":
				jugadores_conectados[id] = player_name
				_addUserToList(player_name, id, status)

		"login":
			if resp.get("status", "") == "OK":
				_sendToChatDisplay("Login exitoso como %s" % mi_nombre)
				_sendGetUserListEvent()

		"match-accepted":
			var data = resp.get("data", {})
			var nombre = _extract_name(resp)
			var mid = data.get("matchId", "")
			_sendToChatDisplay("Jugador %s aceptó tu invitación. Esperando que comience la partida..." % nombre)


		"player-disconnected":
			_deleteUserFromList(_extract_name(resp))

		"public-message":
			var sender = _extract_name(resp)
			var label = "Yo" if sender == mi_nombre else sender
			_sendToChatDisplay("%s: %s" % [label, _extract_data(resp, "playerMsg")])

		"private-message":
			var sender = _extract_name(resp)
			var label = "Yo" if sender == mi_nombre else sender
			_sendToChatDisplay("(Privado de %s): %s" % [label, _extract_data(resp, "message")], true)

		"match-request-received":
			print("Se recibió invitación de partida:", resp)
			invitacion_recibida = _extract_name(resp)
			_sendToChatDisplay("%s quiere jugar contigo!" % invitacion_recibida)
			$VBoxContainer/HBoxContainer/AcceptButton
			$VBoxContainer/HBoxContainer/RejectButton



		"match-start":
			var data = resp.get("data", {})
			oponente = data.get("opponent", {}).get("playerName", "")
			match_id = data.get("matchId", "")
			Global.oponente = oponente
			Global.match_id = match_id
			_sendToChatDisplay("¡La partida ha comenzado con %s!" % oponente)
			get_tree().change_scene_to_file("res://EscenasGenerales/Multiplayer/Multiplayer_Scene.tscn")

func _extract_name(resp: Dictionary) -> String:
	var d = resp.get("data", null)
	match typeof(d):
		TYPE_STRING:
			return d
		TYPE_DICTIONARY:
			return d.get("playerName", d.get("name", "¿Desconocido?"))
	return resp.get("playerName", resp.get("name", "¿Desconocido?"))

func _extract_id(resp: Dictionary) -> String:
	var d = resp.get("data", null)
	if typeof(d) == TYPE_DICTIONARY:
		return d.get("playerId", "")
	return ""

func _extract_data(resp: Dictionary, key: String) -> String:
	var d = resp.get("data", null)
	if typeof(d) == TYPE_DICTIONARY:
		return str(d.get(key, ""))
	return resp.get(key, "")

func _addUserToList(player_name: String, id: String, status := "UNKNOWN"):
	if player_name == "" or id == "":
		return
	for i in range(player_list.item_count):
		var txt = player_list.get_item_text(i)
		if txt.begins_with(player_name):
			return
	var display_name = player_name
	if player_name == mi_nombre:
		display_name += " (Yo)"
	display_name += " [" + status + "]"
	player_list.add_item(display_name)
	player_list.set_item_metadata(player_list.item_count - 1, id)
	jugadores_conectados[id] = player_name



func _deleteUserFromList(user: String):
	for i in range(player_list.item_count):
		var txt = player_list.get_item_text(i)
		if txt == user or txt == user + " (Yo)":
			player_list.remove_item(i)
			return

func _on_input_submitted(message: String):
	_handle_send(message)

func _on_send_pressed():
	_handle_send(input_message.text)

func _handle_send(text: String):
	text = text.strip_edges()
	if text == "":
		return
	var sel = player_list.get_selected_items()
	var target = ""
	if sel.size() > 0:
		target = player_list.get_item_metadata(sel[0])
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
		var nombre_destinatario = jugadores_conectados.get(userId, "¿Desconocido?")
		_sendToChatDisplay("(Privado a %s): %s" % [nombre_destinatario, message], true)

func _sendGetUserListEvent():
	player_list.clear()
	_client.send(JSON.stringify({"event": "get-connected-players"}))

func _updateUserList(users: Array):
	jugadores_conectados.clear()
	player_list.clear()
	for u in users:
		if typeof(u) == TYPE_DICTIONARY:
			var id = u.get("playerId", "")
			var player_name = u.get("playerName", u.get("name", ""))
			var status = u.get("status", "UNKNOWN")
			if id != "":
				jugadores_conectados[id] = player_name
				_addUserToList(player_name, id, status)
				print("Actualizando lista de usuarios: %d jugadores" % users.size())




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
	if sel.size() == 0:
		_sendToChatDisplay("Selecciona un jugador primero.")
		return
	var id = player_list.get_item_metadata(sel[0])
	if id == "":
		_sendToChatDisplay("No se pudo obtener el ID del jugador.")
		return
	_client.send(JSON.stringify({"event": "send-match-request", "data": {"playerId": id}}))
	var nombre = jugadores_conectados.get(id, "Desconocido")
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
