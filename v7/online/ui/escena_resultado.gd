extends Control

# Lógica de resultados de partida
class_name EscenaResultado

# Referencias a UI
@onready var label_resultado: Label = $VBoxContainer/ResultadoContainer/LabelResultado
@onready var label_detalles: Label = $VBoxContainer/DetallesContainer/LabelDetalles
@onready var label_stats: Label = $VBoxContainer/StatsContainer/LabelStats
@onready var boton_revancha: Button = $VBoxContainer/BotonesContainer/BotonRevancha
@onready var boton_menu: Button = $VBoxContainer/BotonesContainer/BotonMenu
@onready var boton_salir: Button = $VBoxContainer/BotonesContainer/BotonSalir

# Variables de resultado
var resultado_partida: String = ""
var vidas_jugador: int = 0
var vidas_oponente: int = 0
var microjuegos_jugados: int = 0
var microjuegos_ganados: int = 0
var tiempo_total: float = 0.0

# Referencias a sistemas
var network_manager: Node
var chat_manager: Node

func _ready():
	print("🏆 EscenaResultado iniciada")
	
	# Obtener referencias
	network_manager = get_node("/root/NetworkManager")
	chat_manager = get_node_or_null("../ChatManager")
	
	# Conectar señales
	if network_manager:
		network_manager.rematch_requested.connect(_on_rematch_requested)
		network_manager.match_quit.connect(_on_match_quit)
		network_manager.connection_status_changed.connect(_on_connection_status_changed)
	
	# Conectar botones
	if boton_revancha:
		boton_revancha.pressed.connect(_on_boton_revancha_pressed)
	if boton_menu:
		boton_menu.pressed.connect(_on_boton_menu_pressed)
	if boton_salir:
		boton_salir.pressed.connect(_on_boton_salir_pressed)
	
	# Cargar datos de resultado
	cargar_datos_resultado()
	
	# Mostrar resultados
	mostrar_resultados()

func cargar_datos_resultado():
	# Obtener datos del resultado de la partida
	if network_manager:
		var player_data = network_manager.get_player_data()
		var match_data = network_manager.get_current_match_id()
		
		print("📊 Cargando datos de resultado...")
		
		# Aquí se cargarían los datos reales de la partida
		# Por ahora usamos valores de ejemplo
		resultado_partida = "victory"  # "victory", "defeat", "draw"
		vidas_jugador = 2
		vidas_oponente = 0
		microjuegos_jugados = 5
		microjuegos_ganados = 3
		tiempo_total = 120.5

func mostrar_resultados():
	# Mostrar resultado principal
	if label_resultado:
		var texto_resultado = ""
		var color_resultado = Color.WHITE
		
		match resultado_partida:
			"victory":
				texto_resultado = "¡VICTORIA! 🎉"
				color_resultado = Color.GREEN
			"defeat":
				texto_resultado = "DERROTA 😿"
				color_resultado = Color.RED
			"draw":
				texto_resultado = "EMPATE 🤝"
				color_resultado = Color.YELLOW
			_:
				texto_resultado = "RESULTADO DESCONOCIDO"
				color_resultado = Color.GRAY
		
		label_resultado.text = texto_resultado
		label_resultado.modulate = color_resultado
	
	# Mostrar detalles
	if label_detalles:
		var texto_detalles = ""
		texto_detalles += "Vidas restantes: " + str(vidas_jugador) + "\n"
		texto_detalles += "Vidas del oponente: " + str(vidas_oponente) + "\n"
		texto_detalles += "Microjuegos totales: " + str(microjuegos_jugados) + "\n"
		texto_detalles += "Microjuegos ganados: " + str(microjuegos_ganados) + "\n"
		
		label_detalles.text = texto_detalles
	
	# Mostrar estadísticas
	if label_stats:
		var porcentaje_exito = 0.0
		if microjuegos_jugados > 0:
			porcentaje_exito = (float(microjuegos_ganados) / float(microjuegos_jugados)) * 100.0
		
		var texto_stats = ""
		texto_stats += "Tiempo total: " + str(int(tiempo_total)) + "s\n"
		texto_stats += "Tasa de éxito: " + str(int(porcentaje_exito)) + "%\n"
		
		if resultado_partida == "victory":
			texto_stats += "¡Excelente trabajo! 🌟\n"
		elif resultado_partida == "defeat":
			texto_stats += "¡Inténtalo de nuevo! 💪\n"
		else:
			texto_stats += "¡Buen juego! 👍\n"
		
		label_stats.text = texto_stats
	
	# Habilitar/deshabilitar botones según el estado
	actualizar_botones()

func actualizar_botones():
	if boton_revancha:
		boton_revancha.disabled = not network_manager.is_in_match()
	
	if boton_menu:
		boton_menu.disabled = false
	
	if boton_salir:
		boton_salir.disabled = false

func _on_boton_revancha_pressed():
	print("🔄 Solicitando revancha...")
	
	if network_manager:
		var success = network_manager.send_rematch_request()
		if success:
			boton_revancha.text = "Esperando respuesta..."
			boton_revancha.disabled = true
			
			# Mostrar mensaje en chat si está disponible
			if chat_manager and chat_manager.has_method("add_system_message"):
				chat_manager.add_system_message("🔄 Solicitando revancha...")
		else:
			print("❌ Error al solicitar revancha")

func _on_boton_menu_pressed():
	print("🏠 Regresando al menú principal...")
	
	# Desconectar de la partida si está activa
	if network_manager and network_manager.is_in_match():
		network_manager.quit_match()
	
	# Cambiar a la escena del menú principal
	var main_menu = load("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
	if main_menu:
		get_tree().change_scene_to_packed(main_menu)
	else:
		print("❌ No se pudo cargar el menú principal")

func _on_boton_salir_pressed():
	print("🚪 Saliendo del juego...")
	
	# Desconectar de la partida y del servidor
	if network_manager:
		if network_manager.is_in_match():
			network_manager.quit_match()
		network_manager.disconnect_from_server()
	
	# Salir del juego
	get_tree().quit()

func _on_rematch_requested():
	print("🔄 El oponente solicita revancha")
	
	# Mostrar diálogo de confirmación
	var dialog = AcceptDialog.new()
	dialog.dialog_text = "¿Quieres jugar otra partida?"
	dialog.title = "Solicitud de Revancha"
	
	# Agregar botones
	dialog.add_button("Aceptar", true, "accept")
	dialog.add_button("Rechazar", false, "reject")
	
	add_child(dialog)
	dialog.popup_centered()
	
	# Conectar respuesta
	dialog.custom_action.connect(_on_rematch_response)

func _on_rematch_response(action):
	if action == "accept":
		print("✅ Revancha aceptada")
		
		# Aceptar la revancha
		if network_manager:
			network_manager.accept_match()
		
		# Cambiar a la escena multijugador
		var multiplayer_scene = load("res://online/core/Multiplayer_Scene.tscn")
		if multiplayer_scene:
			get_tree().change_scene_to_packed(multiplayer_scene)
		else:
			print("❌ No se pudo cargar la escena multijugador")
	
	elif action == "reject":
		print("❌ Revancha rechazada")
		
		# Rechazar la revancha
		if network_manager:
			network_manager.reject_match()

func _on_match_quit():
	print("🚪 El oponente salió de la partida")
	
	# Deshabilitar botón de revancha
	if boton_revancha:
		boton_revancha.disabled = true
		boton_revancha.text = "Oponente desconectado"
	
	# Mostrar mensaje
	if chat_manager and chat_manager.has_method("add_system_message"):
		chat_manager.add_system_message("🚪 El oponente salió de la partida")

func _on_connection_status_changed(connected: bool):
	if not connected:
		print("🔌 Conexión perdida")
		
		# Deshabilitar botones online
		if boton_revancha:
			boton_revancha.disabled = true
			boton_revancha.text = "Sin conexión"
		
		# Mostrar mensaje
		if chat_manager and chat_manager.has_method("add_system_message"):
			chat_manager.add_system_message("🔌 Conexión perdida")

func set_resultado_data(data: Dictionary):
	resultado_partida = data.get("result", "unknown")
	vidas_jugador = data.get("player_lives", 0)
	vidas_oponente = data.get("opponent_lives", 0)
	microjuegos_jugados = data.get("microgames_played", 0)
	microjuegos_ganados = data.get("microgames_won", 0)
	tiempo_total = data.get("total_time", 0.0)
	
	# Actualizar display
	mostrar_resultados()

func get_resultado_data() -> Dictionary:
	return {
		"result": resultado_partida,
		"player_lives": vidas_jugador,
		"opponent_lives": vidas_oponente,
		"microgames_played": microjuegos_jugados,
		"microgames_won": microjuegos_ganados,
		"total_time": tiempo_total
	}