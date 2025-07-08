extends Control

@onready var lista_jugadores = get_node_or_null("VBoxContainer/ListaJugadores")
@onready var campo_nombre = get_node_or_null("VBoxContainer/HBoxContainer/CampoNombre")
@onready var boton_conectar = get_node_or_null("VBoxContainer/HBoxContainer/BotonConectar")
@onready var estado_conexion = get_node_or_null("VBoxContainer/EstadoConexion")
@onready var panel_invitacion = get_node_or_null("PanelInvitacion")
@onready var label_invitacion = get_node_or_null("PanelInvitacion/VBoxContainer/LabelInvitacion")
@onready var boton_aceptar = get_node_or_null("PanelInvitacion/VBoxContainer/HBoxContainer/BotonAceptar")
@onready var boton_rechazar = get_node_or_null("PanelInvitacion/VBoxContainer/HBoxContainer/BotonRechazar")
@onready var boton_volver = get_node_or_null("VBoxContainer/BotonVolver")

var jugadores_online = {}
var mi_nombre = ""
var conectado = false
var invitacion_actual = null

func _ready():
	print("👤 Iniciando ClienteOnline...")
	
	# Conectar botones
	if boton_conectar:
		boton_conectar.pressed.connect(_on_conectar_pressed)
	if boton_aceptar:
		boton_aceptar.pressed.connect(_on_aceptar_invitacion)
	if boton_rechazar:
		boton_rechazar.pressed.connect(_on_rechazar_invitacion)
	if boton_volver:
		boton_volver.pressed.connect(_on_volver_pressed)
	
	# Configurar lista de jugadores
	if lista_jugadores:
		lista_jugadores.item_selected.connect(_on_jugador_selected)
	
	# Ocultar panel de invitación
	if panel_invitacion:
		panel_invitacion.visible = false
	
	# Nombre por defecto
	if campo_nombre:
		campo_nombre.text = "BenjaminCuello"

func _on_conectar_pressed():
	if !conectado:
		conectar_servidor()
	else:
		desconectar_servidor()

func conectar_servidor():
	if !campo_nombre:
		return
		
	mi_nombre = campo_nombre.text.strip_edges()
	if mi_nombre == "":
		if estado_conexion:
			estado_conexion.text = "❌ Ingresa tu nombre"
		return
	
	print("🔌 Conectando al servidor...")
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("127.0.0.1", 8080)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		if estado_conexion:
			estado_conexion.text = "🟡 Conectando..."
		
		# Conectar señales
		multiplayer.connected_to_server.connect(_on_connected_to_server)
		multiplayer.connection_failed.connect(_on_connection_failed)
		multiplayer.server_disconnected.connect(_on_server_disconnected)
	else:
		print("❌ Error al conectar:", error)
		if estado_conexion:
			estado_conexion.text = "❌ Error de conexión"

func _on_connected_to_server():
	conectado = true
	print("✅ Conectado al servidor como:", mi_nombre)
	
	if estado_conexion:
		estado_conexion.text = "🟢 Conectado como: " + mi_nombre
	if boton_conectar:
		boton_conectar.text = "🔌 Desconectar"
	
	# Registrarse en el servidor
	registrar_jugador.rpc(mi_nombre)

func _on_connection_failed():
	print("❌ Conexión fallida")
	if estado_conexion:
		estado_conexion.text = "❌ No se pudo conectar al servidor"

func _on_server_disconnected():
	conectado = false
	print("🔌 Desconectado del servidor")
	if estado_conexion:
		estado_conexion.text = "🔴 Desconectado"
	if boton_conectar:
		boton_conectar.text = "🔌 Conectar"
	if lista_jugadores:
		lista_jugadores.clear()

func desconectar_servidor():
	multiplayer.multiplayer_peer = null
	_on_server_disconnected()

func _on_jugador_selected(index: int):
	if !lista_jugadores:
		return
		
	var jugador_id = lista_jugadores.get_item_metadata(index)
	if jugador_id == null:
		return
		
	var jugador = jugadores_online.get(jugador_id)
	if jugador and jugador.estado == "disponible":
		mostrar_menu_invitacion(jugador_id, jugador.nombre)

func mostrar_menu_invitacion(jugador_id: int, nombre: String):
	var popup = AcceptDialog.new()
	popup.title = "Invitar a " + nombre
	popup.size = Vector2(300, 400)
	
	var vbox = VBoxContainer.new()
	var label = Label.new()
	label.text = "Selecciona un microjuego:"
	vbox.add_child(label)
	
	var microjuegos = [
		"🎯 Apunta y Dispara",
		"🐱 Escondite Gatuno", 
		"🎣 Pesca en Hielo",
		"🎮 Aleatorio"
	]
	
	for microjuego in microjuegos:
		var boton = Button.new()
		boton.text = microjuego
		boton.custom_minimum_size = Vector2(250, 40)
		boton.pressed.connect(_on_microjuego_selected.bind(jugador_id, microjuego, popup))
		vbox.add_child(boton)
	
	popup.add_child(vbox)
	add_child(popup)
	popup.popup_centered()

func _on_microjuego_selected(jugador_id: int, microjuego: String, popup: Window):
	popup.queue_free()
	
	print("📨 Enviando invitación para:", microjuego)
	enviar_invitacion.rpc(jugador_id, microjuego)
	
	if estado_conexion:
		estado_conexion.text = "📨 Invitación enviada..."

func _on_aceptar_invitacion():
	if invitacion_actual:
		print("✅ Aceptando invitación para:", invitacion_actual.microjuego)
		responder_invitacion.rpc(invitacion_actual.de.id, true, invitacion_actual.microjuego)
		if panel_invitacion:
			panel_invitacion.visible = false
		invitacion_actual = null

func _on_rechazar_invitacion():
	if invitacion_actual:
		print("❌ Rechazando invitación")
		responder_invitacion.rpc(invitacion_actual.de.id, false, invitacion_actual.microjuego)
		if panel_invitacion:
			panel_invitacion.visible = false
		invitacion_actual = null

func _on_volver_pressed():
	if conectado:
		desconectar_servidor()
	get_tree().change_scene_to_file("res://v7/Online/MenuOnline.tscn")

# Funciones RPC que reciben datos del servidor
@rpc("any_peer", "call_local")
func actualizar_lista_jugadores(lista: Dictionary):
	jugadores_online = lista
	actualizar_ui_jugadores()

func actualizar_ui_jugadores():
	if !lista_jugadores:
		return
		
	lista_jugadores.clear()
	print("📋 Actualizando lista de jugadores:", jugadores_online.size())
	
	for jugador_id in jugadores_online:
		var jugador = jugadores_online[jugador_id]
		var estado_emoji = "🟢" if jugador.estado == "disponible" else "🔴"
		var texto = estado_emoji + " " + jugador.nombre
		
		lista_jugadores.add_item(texto)
		var item_index = lista_jugadores.get_item_count() - 1
		lista_jugadores.set_item_metadata(item_index, jugador_id)
		
		print("  - " + texto)

@rpc("any_peer")
func recibir_invitacion(de_jugador: Dictionary, microjuego: String):
	print("📨 Invitación recibida de:", de_jugador.nombre, "para:", microjuego)
	
	invitacion_actual = {
		"de": de_jugador,
		"microjuego": microjuego
	}
	
	if label_invitacion:
		label_invitacion.text = de_jugador.nombre + " te invita a jugar:\n" + microjuego
	if panel_invitacion:
		panel_invitacion.visible = true

@rpc("any_peer")
func invitacion_rechazada(nombre_jugador: String):
	print("❌ Invitación rechazada por:", nombre_jugador)
	if estado_conexion:
		estado_conexion.text = "❌ " + nombre_jugador + " rechazó la invitación"

@rpc("any_peer")
func iniciar_partida_cooperativa(microjuego: String, otro_jugador_id: int):
	print("🎮 Iniciando partida cooperativa:", microjuego, "con jugador:", otro_jugador_id)
	
	# Configurar modo multijugador
	if has_node("/root/Global"):
		Global.otro_jugador_id = otro_jugador_id
		Global.modo_multijugador = true
	
	# Convertir nombre a ruta y cargar microjuego
	var ruta_microjuego = convertir_nombre_a_ruta(microjuego)
	print("🎯 Cargando microjuego:", ruta_microjuego)
	get_tree().change_scene_to_file(ruta_microjuego)

func convertir_nombre_a_ruta(nombre: String) -> String:
	match nombre:
		"🎯 Apunta y Dispara":
			return "res://Microjuegos/Emily/3_Apunta y dispara/Escena/main.tscn"
		"🐱 Escondite Gatuno":
			return "res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn"
		"🎣 Pesca en Hielo":
			return "res://Microjuegos/Branco/6_Pesca en hielo/Escena/6_Pesca_Hielo.tscn"
		"🎮 Aleatorio":
			return "res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn"
		_:
			return "res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn"

# RPCs que se envían al servidor
@rpc("any_peer")
func registrar_jugador(nombre: String):
	pass

@rpc("any_peer") 
func enviar_invitacion(a_jugador_id: int, microjuego: String):
	pass

@rpc("any_peer")
func responder_invitacion(a_jugador_id: int, aceptada: bool, microjuego: String):
	pass
