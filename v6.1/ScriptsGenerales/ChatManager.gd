extends Control

var invitacion_recibida = ""
var match_id = ""
var oponente = ""
var mi_nombre = Global.username

var _host = "ws://ucn-game-server.martux.cl:4010/?gameId=E&playerName=%s" % mi_nombre
@onready var _client: WebSocketClient = $WebSocketClient

@onready var chat_display: TextEdit = $VBoxContainer/MainPanel/ChatDisplay
@onready var player_list: ItemList = $VBoxContainer/MainPanel/UserPanel/UserList
@onready var input_message: LineEdit = $VBoxContainer/Commands/InputMessage
@onready var send_button: Button = $VBoxContainer/Commands/SendButton

func _on_web_socket_client_connection_closed():
	var ws = _client.get_socket()
	_sendToChatDisplay("Client just disconnected with code: %s, reason: %s" % [ws.get_close_code(), ws.get_close_reason()])

func _on_web_socket_client_connected_to_server():
	_sendToChatDisplay("Conexión establecida con el servidor. Enviando login...")
	var login_payload = {
		"event": "login",
		"data": {
			"gameKey": "TXWGJ7"
		}
	}
	print("Payload login → ", JSON.stringify(login_payload))
	_client.send(JSON.stringify(login_payload))
	_sendGetUserListEvent()

func _on_web_socket_client_message_received(message: String):
	var response = JSON.parse_string(message)
	print("Mensaje recibido del servidor:", message)
	if response == null:
		_sendToChatDisplay("[Error] JSON no válido recibido")
		return

	match(response.get("event", "")):
		"connected-to-server":
			_sendToChatDisplay("You are connected to the server!")
			_addUserToList(mi_nombre)

		"public-message":
			var sender = get_player_name(response)
			var display = str("Yo") if sender == mi_nombre else str(sender)
			_sendToChatDisplay("%s: %s" % [display, get_data_value(response, "playerMsg")])
		
		"private-message":
			var sender = get_player_name(response)
			var display = str("Yo") if sender == mi_nombre else str(sender)
			_sendToChatDisplay("(Privado de %s): %s" % [display, get_data_value(response, "message")], true)

		"get-connected-players":
			_updateUserList(response.get("data", []))

		"player-connected":
			_addUserToList(get_player_name(response))
			_sendGetUserListEvent()

		"player-disconnected":
			_deleteUserFromList(get_player_name(response))

		"match-request-received":
			var player = get_player_name(response)
			_sendToChatDisplay("%s quiere jugar contigo!" % player)
			invitacion_recibida = player
			$VBoxContainer/AcceptButton.visible = true
			$VBoxContainer/RejectButton.visible = true

		"match-start":
			var opp_data = response.get("data", {}).get("opponent", {})
			Global.oponente = opp_data.get("playerName", "")
			Global.match_id = response.get("data", {}).get("matchId", "")
			
			_sendToChatDisplay("¡La partida ha comenzado con %s!" % Global.oponente)
			
			get_tree().change_scene_to_file("res://EscenasGenerales/Multiplayer/Multiplayer_Scene.tscn")


func get_player_name(response: Dictionary) -> String:
	if response.has("data") and typeof(response["data"]) == TYPE_DICTIONARY:
		return response["data"].get("playerName", "¿Desconocido?")
	return response.get("playerName", "¿Desconocido?")

func get_data_value(response: Dictionary, key: String) -> Variant:
	if response.has("data") and typeof(response["data"]) == TYPE_DICTIONARY:
		return response["data"].get(key, "")
	return ""

func _addUserToList(user: String):
	if user == "":
		return
	for i in range(player_list.item_count):
		if player_list.get_item_text(i) == user or player_list.get_item_text(i) == user + " (Yo)":
			return
	var display_name = user
	if user == mi_nombre:
		display_name += " (Yo)"
	player_list.add_item(display_name)
	_sendToChatDisplay("Jugador conectado: %s" % display_name)

func _on_input_submitted(message: String):
	if message.strip_edges() == "":
		return
	var selected = player_list.get_selected_items()
	var destinatario = ""
	if selected.size() > 0:
		destinatario = player_list.get_item_text(selected[0]).replace(" (Yo)", "")
	_sendMessage(message, destinatario)
	input_message.text = ""
	input_message.grab_focus()

func _on_send_pressed():
	if input_message.text == "":
		return
	var selected = player_list.get_selected_items()
	var destinatario = ""
	if selected.size() > 0:
		destinatario = player_list.get_item_text(selected[0]).replace(" (Yo)", "")
	_sendMessage(input_message.text, destinatario)
	input_message.text = ""
	input_message.grab_focus()

func _on_connect_toggled(pressed):
	if not pressed:
		_client.close()
		return
	_sendToChatDisplay("Connecting to host: %s." % [_host])
	var err = _client.connect_to_url(_host)
	if err != OK:
		_sendToChatDisplay("Error connecting to host: %s" % [_host])
		return

func _sendToChatDisplay(msg: String, is_private := false):
	print(msg)
	if is_private:
		chat_display.text += "[Privado] %s\n" % msg
	else:
		chat_display.text += "%s\n" % msg

func _sendMessage(message: String, userId: String = ''):
	var action = "send-private-message" if userId != "" else "send-public-message"
	var dataToSend = {
		"event": action,
		"data": {
			"message": message
		}
	}
	if userId != "":
		dataToSend["data"]["playerName"] = userId
	_client.send(JSON.stringify(dataToSend))
	if userId == "":
		_sendToChatDisplay("Yo: %s" % message)
	else:
		_sendToChatDisplay("(Privado a %s): %s" % [userId, message], true)

func _sendGetUserListEvent():
	var dataToSend = {
		"event": "get-connected-players"
	}
	_client.send(JSON.stringify(dataToSend))

func _updateUserList(users: Array):
	player_list.clear()
	for user in users:
		_addUserToList(user)

func _deleteUserFromList(userId: String):
	for i in range(player_list.item_count):
		var display_name = player_list.get_item_text(i)
		if display_name == userId or display_name == userId + " (Yo)":
			player_list.remove_item(i)
			return

func _on_boton_volver_pressed() -> void:
	print("Volviendo al menú")
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func _on_button_pressed() -> void:
	print("Volviendo al menú")
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func _on_invite_button_pressed() -> void:
	var selected = player_list.get_selected_items()
	if selected.size() == 0:
		_sendToChatDisplay("Selecciona un jugador primero.")
		return
	var target_name = player_list.get_item_text(selected[0]).replace(" (Yo)", "")
	var payload = {
		"event": "send-match-request",
		"data": {
			"playerName": target_name
		}
	}
	_client.send(JSON.stringify(payload))
	_sendToChatDisplay("Solicitud enviada a %s" % target_name)

func _on_accept_button_pressed():
	var payload = {
		"event": "accept-match",
		"data": {
			"playerName": invitacion_recibida
		}
	}
	_client.send(JSON.stringify(payload))
	_sendToChatDisplay("Aceptaste la partida con %s" % invitacion_recibida)
	_ocultar_botones_match()

func _on_reject_button_pressed():
	var payload = {
		"event": "reject-match",
		"data": {
			"playerName": invitacion_recibida
		}
	}
	_client.send(JSON.stringify(payload))
	_sendToChatDisplay("Rechazaste la partida con %s" % invitacion_recibida)
	_ocultar_botones_match()

func _ocultar_botones_match():
	$VBoxContainer/AcceptButton.visible = false
	$VBoxContainer/RejectButton.visible = false
	invitacion_recibida = ""
