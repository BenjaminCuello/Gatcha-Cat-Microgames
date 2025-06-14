extends Node

# Vida y control de microjuegos
var vidas = 3
var microjuego_actual = 0
var max_microjuegos = 30

# Lista de microjuegos disponibles
var lista_microjuegos = [
	"res://Microjuegos/Andres/26_Atrapa el ratón/Escena/atrapar_raton.tscn",
	"res://Microjuegos/Cuello/16_Tecla gatuna/Escena/Tecla gatuna (1).tscn",
	"res://Microjuegos/Cuello/18_Gato equilibrio/Escena/Gato equilibrio (2).tscn",
	"res://Microjuegos/Cuello/19_  Baile rítmico/Escena/Baile rítmico (5).tscn",
	"res://Microjuegos/Matias/11_Morder al muñeco/Escena/11_Morder_al_muñeco.tscn",
	"res://Microjuegos/Ramiro/21_¡Abrelatas!/Escena/Abrelatas (3).tscn",
	"res://Microjuegos/Ramiro/22_Atrápalo/Escena/Atrapalo (6).tscn",
	"res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn",
	"res://Microjuegos/Branco/10_Juego de cartas/Escena/10_Cartas.tscn"
]
# Elegir uno al azar
func obtener_microjuego_aleatorio() -> String:
	return lista_microjuegos.pick_random()

# Reiniciar el juego
func reiniciar():
	vidas = 3
	microjuego_actual = 0
