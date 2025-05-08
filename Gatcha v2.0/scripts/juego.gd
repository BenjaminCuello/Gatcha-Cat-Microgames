extends Node

# Vida y control de microjuegos
var vidas = 3
var microjuego_actual = 0
var max_microjuegos = 30

# Lista de microjuegos disponibles
var lista_microjuegos = [
	"res://microjuegos/microjuego1.tscn",
	"res://microjuegos/micro_abrelatas.tscn",
	"res://microjuegos/micro_atrapalo.tscn"
	
	# Puedes agregar más microjuegos aquí después
	]

# Elegir uno al azar
func obtener_microjuego_aleatorio() -> String:
	return lista_microjuegos.pick_random()

# Reiniciar el juego
func reiniciar():
	vidas = 3
	microjuego_actual = 0
	max_microjuegos = 30
