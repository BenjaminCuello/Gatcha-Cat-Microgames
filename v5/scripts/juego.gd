extends Node

# Vida y control de microjuegos
var vidas = 3
var microjuego_actual = 0
var max_microjuegos = 30

# Lista de microjuegos disponibles
var lista_microjuegos = [
	#"res://microjuegos/1_Escondite_gatuno.tscn",
	"res://microjuegos/9_Flappy_cat.tscn"
	#"res://microjuegos/10_Cartas.tscn",
	#"res://microjuegos/11_Morder_al_muñeco.tscn",
	#"res://microjuegos/12_Gato_lavarse.tscn", falta conectarlo con victoria derrota al sistema
	#"res://microjuegos/16_Tecla_gatuna.tscn",
	#"res://microjuegos/18_Gato_equilibrio.tscn",
	#"res://microjuegos/19_Ronroneo_ritmico.tscn",
	#"res://microjuegos/21_Abrelatas.tscn",
	#"res://microjuegos/22_Atrapalo.tscn",
	#"res://microjuegos/26_Atrapar_raton.tscn"
]
# Elegir uno al azar
func obtener_microjuego_aleatorio() -> String:
	return lista_microjuegos.pick_random()

# Reiniciar el juego
func reiniciar():
	vidas = 3
	microjuego_actual = 0
