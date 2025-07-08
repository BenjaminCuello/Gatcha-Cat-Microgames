extends Node

var jugadores_online = {}
var invitaciones_pendientes = {}

func _ready():
	print("🌐 Servidor central iniciado")
	
	# Conectar señales del multijugador
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_connected(id: int):
	print("👤 Jugador conectado:", id)
	# Enviar lista de jugadores al nuevo jugador
	call_deferred("enviar_lista_jugadores", id)

func _on_peer_disconnected(id: int):
	print("👤 Jugador desconectado:", id)
	if id in jugadores_online:
		var nombre = jugadores_online[id].nombre
		jugadores_online.erase(id)
		print("📝 Jugador", nombre, "eliminado de la lista")
	
	# Notificar a todos los jugadores conectados
	actualizar_lista_jugadores.rpc(jugadores_online)

func enviar_lista_jugadores(id: int):
	if multiplayer.multiplayer_peer != null:
		actualizar_lista_jugadores.rpc_id(id, jugadores_online)

@rpc("any_peer")
func registrar_jugador(nombre: String):
	var sender_id = multiplayer.get_remote_sender_id()
	
	jugadores_online[sender_id] = {
		"nombre": nombre,
		"estado": "disponible",
		"id": sender_id
	}
	
	print("📝 Jugador registrado:", nombre, "(ID:", sender_id, ")")
	
	# Enviar lista actualizada a todos
	actualizar_lista_jugadores.rpc(jugadores_online)

@rpc("any_peer")
func enviar_invitacion(a_jugador_id: int, microjuego: String):
	var sender_id = multiplayer.get_remote_sender_id()
	
	print("📨 Invitación de", sender_id, "para", a_jugador_id, ":", microjuego)
	
	if a_jugador_id in jugadores_online:
		var remitente = jugadores_online[sender_id]
		# Enviar invitación al jugador objetivo
		recibir_invitacion.rpc_id(a_jugador_id, remitente, microjuego)
		print("✅ Invitación enviada correctamente")
	else:
		print("❌ Jugador objetivo no encontrado")

@rpc("any_peer")
func responder_invitacion(a_jugador_id: int, aceptada: bool, microjuego: String):
	var sender_id = multiplayer.get_remote_sender_id()
	
	print("📬 Respuesta de invitación:", "Aceptada:" if aceptada else "Rechazada")
	
	if aceptada:
		print("🎮 Iniciando partida multijugador...")
		# Cambiar estado de ambos jugadores
		if sender_id in jugadores_online:
			jugadores_online[sender_id]["estado"] = "jugando"
		if a_jugador_id in jugadores_online:
			jugadores_online[a_jugador_id]["estado"] = "jugando"
		
		# Enviar comando para iniciar partida a ambos
		iniciar_partida_cooperativa.rpc_id(a_jugador_id, microjuego, sender_id)
		iniciar_partida_cooperativa.rpc_id(sender_id, microjuego, a_jugador_id)
		
		# Actualizar lista para todos los demás
		actualizar_lista_jugadores.rpc(jugadores_online)
	else:
		# Notificar rechazo
		if a_jugador_id in jugadores_online:
			var nombre_rechazador = jugadores_online[sender_id]["nombre"]
			invitacion_rechazada.rpc_id(a_jugador_id, nombre_rechazador)

@rpc("any_peer")
func partida_terminada(jugador_id: int):
	print("🏁 Partida terminada para jugador:", jugador_id)
	if jugador_id in jugadores_online:
		jugadores_online[jugador_id]["estado"] = "disponible"
		actualizar_lista_jugadores.rpc(jugadores_online)

# RPCs que se envían a los clientes
@rpc("any_peer", "call_local")
func actualizar_lista_jugadores(lista: Dictionary):
	pass

@rpc("any_peer")
func recibir_invitacion(de_jugador: Dictionary, microjuego: String):
	pass

@rpc("any_peer")
func invitacion_rechazada(nombre_jugador: String):
	pass

@rpc("any_peer")
func iniciar_partida_cooperativa(microjuego: String, otro_jugador_id: int):
	pass
