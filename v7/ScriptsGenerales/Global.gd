# Global.gd - Singleton para variables globales
extends Node

# Variables del jugador
var username := ""
var player_id := ""

# Variables de partida multijugador
var match_id: String = ""
var oponente: String = ""
var is_multiplayer_mode := false

# Variables adicionales
var current_difficulty := 1
var is_online := false

# Señales
signal multiplayer_mode_changed(enabled: bool)
signal player_data_updated

func _ready():
	print("=== Global singleton inicializado ===")

# Función para limpiar datos de partida
func limpiar_datos_partida():
	match_id = ""
	oponente = ""
	is_multiplayer_mode = false
	print("🧹 Datos de partida limpiados")

# Función para configurar partida multijugador
func configurar_partida_multijugador(id: String, oponente_name: String):
	match_id = id
	oponente = oponente_name
	is_multiplayer_mode = true
	multiplayer_mode_changed.emit(true)
	print("🎮 Partida multijugador configurada - ID:", match_id, "Oponente:", oponente)

# Función para configurar datos del jugador
func configurar_jugador(name: String, id: String = ""):
	username = name
	player_id = id
	player_data_updated.emit()
	print("👤 Jugador configurado - Nombre:", username, "ID:", player_id)

# Función para verificar si está en modo multijugador
func esta_en_multijugador() -> bool:
	return is_multiplayer_mode

# Función para verificar si está online
func esta_online() -> bool:
	return is_online and WebSocketManager.is_player_connected()

# Función para configurar estado online
func configurar_estado_online(online: bool):
	is_online = online
	print("🌐 Estado online:", "Conectado" if online else "Desconectado")

# Función para obtener información completa del jugador
func obtener_info_jugador() -> Dictionary:
	return {
		"username": username,
		"player_id": player_id,
		"is_online": esta_online(),
		"is_multiplayer": is_multiplayer_mode,
		"match_id": match_id,
		"opponent": oponente
	}
