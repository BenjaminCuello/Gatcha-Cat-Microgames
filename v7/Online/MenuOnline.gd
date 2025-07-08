extends Control

@onready var boton_servidor = get_node_or_null("VBoxContainer/SectionServidor/BotonServidor")
@onready var boton_cliente = get_node_or_null("VBoxContainer/SectionCliente/BotonCliente")
@onready var boton_volver = get_node_or_null("VBoxContainer/Botones/BotonVolver")
@onready var estado_conexion = get_node_or_null("VBoxContainer/EstadoConexion")

var servidor_activo = false

func _ready():
	print("🌐 Iniciando MenuOnline...")
	
	# Conectar botones
	if boton_servidor:
		boton_servidor.pressed.connect(_on_servidor_pressed)
	if boton_cliente:
		boton_cliente.pressed.connect(_on_cliente_pressed)
	if boton_volver:
		boton_volver.pressed.connect(_on_volver_pressed)
	
	# Estado inicial
	if estado_conexion:
		estado_conexion.text = "🔴 Desconectado"

func _on_servidor_pressed():
	if !servidor_activo:
		print("🖥️ Iniciando servidor...")
		iniciar_servidor()
	else:
		print("🛑 Deteniendo servidor...")
		detener_servidor()

func _on_cliente_pressed():
	print("👤 Abriendo cliente...")
	get_tree().change_scene_to_file("res://v7/Online/ClienteOnline.tscn")

func _on_volver_pressed():
	print("🔙 Volviendo al menú principal...")
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")

func iniciar_servidor():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(8080, 20)
	
	if error == OK:
		multiplayer.multiplayer_peer = peer
		servidor_activo = true
		
		# Cargar y agregar el script del servidor
		var servidor_script = preload("res://Online/ServidorCental.gd")
		var servidor_node = Node.new()
		servidor_node.set_script(servidor_script)
		add_child(servidor_node)
		
		boton_servidor.text = "🛑 Detener Servidor"
		estado_conexion.text = "🟢 Servidor activo en puerto 8080"
		print("✅ Servidor iniciado correctamente")
	else:
		print("❌ Error al iniciar servidor:", error)
		estado_conexion.text = "❌ Error al iniciar servidor"

func detener_servidor():
	multiplayer.multiplayer_peer = null
	servidor_activo = false
	boton_servidor.text = "🖥️ Iniciar Servidor"
	estado_conexion.text = "🔴 Servidor detenido"
	print("🛑 Servidor detenido")
