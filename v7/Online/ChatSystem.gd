extends Node

# Configuración de UI
var size_multiplier: float = 1.5
var position_offset: Vector2 = Vector2(75, 150)

# Referencias a nodos UI
var chat_ui: Control
var chat_messages: VBoxContainer
var message_input: LineEdit
var send_button: Button
var chat_mode_button: Button

# Configuración del chat
var max_messages = 50
var chat_visible = true

# Variables para chat privado
var chat_mode = "PUBLIC"  # "PUBLIC" o "PRIVATE"
var private_chat_player_name = ""
var private_chat_player_id = ""

func _ready():
	print("=== Iniciando sistema de chat ===")
	call_deferred("create_chat_ui")
	
	# Conectar con NetworkManager
	if NetworkManager:
		NetworkManager.private_message_received.connect(_on_private_message_received)
		NetworkManager.chat_message_received.connect(_on_public_message_received)
		NetworkManager.connection_status_changed.connect(_on_connection_status_changed)

func create_chat_ui():
	print("Creando UI del chat...")
	
	var main_scene = get_tree().current_scene
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "ChatLayer"
	main_scene.call_deferred("add_child", canvas_layer)
	
	await get_tree().process_frame
	setup_chat_interface(canvas_layer)

func setup_chat_interface(canvas_layer: CanvasLayer):
	print("Configurando interfaz del chat...")
	
	# Contenedor principal
	chat_ui = Control.new()
	chat_ui.name = "ChatUI"
	chat_ui.position = position_offset
	chat_ui.size = Vector2(400 * size_multiplier, 500 * size_multiplier)
	canvas_layer.add_child(chat_ui)
	
	# Fondo
	var bg_panel = Panel.new()
	bg_panel.position = Vector2.ZERO
	bg_panel.size = chat_ui.size
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.8)
	style_box.corner_radius_top_left = int(5 * size_multiplier)
	style_box.corner_radius_top_right = int(5 * size_multiplier)
	bg_panel.add_theme_stylebox_override("panel", style_box)
	chat_ui.add_child(bg_panel)
	
	# Botón de modo de chat
	chat_mode_button = Button.new()
	chat_mode_button.text = "🌐 Público"
	chat_mode_button.position = Vector2(5 * size_multiplier, 5 * size_multiplier)
	chat_mode_button.size = Vector2(120 * size_multiplier, 30 * size_multiplier)
	chat_mode_button.add_theme_font_size_override("font_size", int(10 * size_multiplier))
	chat_mode_button.pressed.connect(_on_chat_mode_button_pressed)
	chat_ui.add_child(chat_mode_button)
	
	# Área de mensajes
	var scroll_container = ScrollContainer.new()
	scroll_container.position = Vector2(5 * size_multiplier, 40 * size_multiplier)
	scroll_container.size = Vector2(390 * size_multiplier, 410 * size_multiplier)
	chat_ui.add_child(scroll_container)
	
	chat_messages = VBoxContainer.new()
	chat_messages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(chat_messages)
	
	# Área de input
	var input_container = HBoxContainer.new()
	input_container.position = Vector2(5 * size_multiplier, 445 * size_multiplier)
	input_container.size = Vector2(390 * size_multiplier, 50 * size_multiplier)
	chat_ui.add_child(input_container)
	
	message_input = LineEdit.new()
	message_input.placeholder_text = "Escribe tu mensaje..."
	message_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	message_input.add_theme_font_size_override("font_size", int(12 * size_multiplier))
	input_container.add_child(message_input)
	
	send_button = Button.new()
	send_button.text = "Enviar"
	send_button.size = Vector2(80 * size_multiplier, 40 * size_multiplier)
	send_button.add_theme_font_size_override("font_size", int(12 * size_multiplier))
	input_container.add_child(send_button)
	
	connect_signals()
	add_system_message("Chat iniciado. ¡Bienvenido!")
	print("=== Chat listo ===")

func connect_signals():
	if message_input:
		message_input.text_submitted.connect(_on_message_submitted)
	
	if send_button:
		send_button.pressed.connect(_on_send_button_pressed)

func _on_chat_mode_button_pressed():
	if chat_mode == "PRIVATE":
		set_chat_mode("PUBLIC")
		add_system_message("📢 Cambiado a chat público")
	else:
		add_system_message("💬 Usa el botón 💬 en la lista de jugadores para chatear en privado")

func _on_message_submitted(text: String):
	send_chat_message(text)

func _on_send_button_pressed():
	send_chat_message(message_input.text)

func send_chat_message(text: String):
	if text.strip_edges() == "":
		return
	
	if text.begins_with("/"):
		handle_chat_command(text)
	else:
		if chat_mode == "PRIVATE":
			if private_chat_player_id != "":
				if NetworkManager.send_private_message(private_chat_player_id, text):
					add_chat_message("Tú → " + private_chat_player_name, text)
			else:
				add_system_message("⚠️ No hay chat privado activo")
		else:
			add_chat_message("Tú", text)
			NetworkManager.send_public_message(text)
	
	message_input.text = ""

func handle_chat_command(command: String):
	var parts = command.split(" ", false, 1)
	var cmd = parts[0].to_lower()
	
	match cmd:
		"/help":
			add_system_message("=== Comandos disponibles ===")
			add_system_message("/help - Mostrar ayuda")
			add_system_message("/clear - Limpiar chat")
			add_system_message("/test - Mensaje de prueba")
			add_system_message("/toggle - Mostrar/ocultar chat")
			add_system_message("/public - Cambiar a chat público")
		"/clear":
			clear_chat()
		"/players", "/refresh":
			NetworkManager.request_online_players()
			add_system_message("🔄 Actualizando lista de jugadores...")
		"/test":
			add_system_message("¡Este es un mensaje de prueba!")
		"/toggle":
			toggle_chat_visibility()
		"/public":
			set_chat_mode("PUBLIC")
			add_system_message("📢 Cambiado a chat público")
		_:
			add_system_message("Comando desconocido: " + cmd)

func clear_chat():
	if chat_messages:
		for child in chat_messages.get_children():
			child.queue_free()
	add_system_message("Chat limpiado")

func toggle_chat_visibility():
	chat_visible = !chat_visible
	if chat_ui:
		chat_ui.visible = chat_visible

# Funciones para chat privado
func start_private_chat(player_name: String, player_id: String):
	private_chat_player_name = player_name
	private_chat_player_id = player_id
	set_chat_mode("PRIVATE")
	add_system_message("💬 Chat privado iniciado con " + player_name)

func set_chat_mode(mode: String):
	chat_mode = mode
	
	if chat_mode == "PRIVATE":
		chat_mode_button.text = "💬 " + private_chat_player_name
		chat_mode_button.modulate = Color.LIGHT_BLUE
		message_input.placeholder_text = "Mensaje privado para " + private_chat_player_name + "..."
	else:
		chat_mode_button.text = "🌐 Público"
		chat_mode_button.modulate = Color.WHITE
		message_input.placeholder_text = "Escribe tu mensaje..."
		private_chat_player_name = ""
		private_chat_player_id = ""

# Event handlers
func _on_private_message_received(sender: String, player_id: String, message: String):
	add_chat_message(sender + " → Tú", message)
	
	if chat_mode != "PRIVATE" or private_chat_player_id != player_id:
		add_system_message("💡 Usa el botón 💬 para responder en privado a " + sender)

func _on_public_message_received(sender: String, message: String):
	add_chat_message(sender, message)

func _on_connection_status_changed(connected: bool):
	if connected:
		add_system_message("🟢 Conectado al servidor")
	else:
		add_system_message("🔴 Desconectado del servidor")

func on_message_received(sender: String, message: String):
	add_chat_message(sender, message)

func add_chat_message(sender: String, message: String):
	if not chat_messages:
		return
	
	var timestamp = get_safe_timestamp()
	var label = Label.new()
	label.text = "[" + timestamp + "] " + sender + ": " + message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.y = 20 * size_multiplier
	label.add_theme_font_size_override("font_size", int(11 * size_multiplier))
	
	# Colores según el tipo de mensaje
	if sender == "Sistema":
		label.modulate = Color.DARK_ORCHID
	elif sender == "Tú" or sender.begins_with("Tú →"):
		label.modulate = Color.CADET_BLUE
	elif sender.contains("→ Tú"):
		label.modulate = Color.LIGHT_GREEN
	else:
		label.modulate = Color.WHITE
	
	chat_messages.add_child(label)
	
	# Limitar mensajes
	if chat_messages.get_child_count() > max_messages:
		chat_messages.get_child(0).queue_free()
	
	call_deferred("scroll_to_bottom")

func add_system_message(message: String):
	add_chat_message("Sistema", message)

func get_safe_timestamp() -> String:
	var datetime_dict = Time.get_datetime_dict_from_system()
	var hour = str(datetime_dict.hour).pad_zeros(2)
	var minute = str(datetime_dict.minute).pad_zeros(2)
	return hour + ":" + minute

func scroll_to_bottom():
	if not chat_messages:
		return
		
	var scroll_container = chat_messages.get_parent()
	if scroll_container is ScrollContainer:
		await get_tree().process_frame
		var scrollbar = scroll_container.get_v_scroll_bar()
		if scrollbar:
			scroll_container.scroll_vertical = int(scrollbar.max_value)

func _exit_tree():
	if chat_ui and chat_ui.get_parent():
		chat_ui.get_parent().queue_free()
