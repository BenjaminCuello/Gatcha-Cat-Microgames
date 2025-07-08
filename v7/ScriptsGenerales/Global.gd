# Global.gd - Singleton para variables globales
extends Node

var username := ""
var match_id: String = ""
var oponente: String = ""

# Variables adicionales que puedas necesitar
var is_multiplayer_mode := false
var current_difficulty := 1

# NUEVAS VARIABLES PARA OPCIONES
var mostrar_fps := false
var dificultad_por_defecto := 2 # Por defecto "Normal" (índice 2 del OptionButton)

func _ready():
	print("Global singleton inicializado")

# Función para limpiar datos de partida
func limpiar_datos_partida():
	match_id = ""
	oponente = ""
	is_multiplayer_mode = false
	print("Datos de partida limpiados")

# Función para configurar partida multijugador
func configurar_partida_multijugador(id: String, oponente_name: String):
	match_id = id
	oponente = oponente_name
	is_multiplayer_mode = true
	print("Partida multijugador configurada - ID:", match_id, "Oponente:", oponente)

# Puedes agregar getters y setters si lo prefieres, pero no son estrictamente necesarios.
# Ejemplo:
# func set_mostrar_fps(value: bool):
#     mostrar_fps = value
# func get_mostrar_fps() -> bool:
#     return mostrar_fps
