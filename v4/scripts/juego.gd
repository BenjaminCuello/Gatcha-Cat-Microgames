extends Node

# Vida y control de microjuegos
var vidas = 3
var microjuego_actual = 0
var max_microjuegos = 30

# Lista de microjuegos disponibles
var lista_microjuegos = [
	"res://microjuegos/atrapar_raton.tscn"
]

'''var lista_microjuegos = [
	"res://microjuegos/Tecla gatuna (1).tscn",
	"res://microjuegos/Gato equilibrio (2).tscn",
	"res://microjuegos/Abrelatas (3).tscn",
	"res://microjuegos/Morder al muñeco(4).tscn",
	"res://microjuegos/Baile rítmico (5).tscn",
	"res://microjuegos/Atrapalo (6).tscn",
]'''


# Elegir uno al azar
func obtener_microjuego_aleatorio() -> String:
	return lista_microjuegos.pick_random()

# Reiniciar el juego
func reiniciar():
	vidas = 3
	microjuego_actual = 0
