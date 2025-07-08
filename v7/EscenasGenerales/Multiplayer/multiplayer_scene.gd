extends Node

@onready var game_logic = preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

# Variables para el flujo de la partida
var microjuegos := ["res://Microjuegos/Microjuego1.tscn", "res://Microjuegos/Microjuego2.tscn"]
var indice_actual := 0
var microjuego_actual: Node = null

func _ready():
	add_child(game_logic)
	game_logic.total_microjuegos = microjuegos.size()
	game_logic.oponente = "NombreDelOponente" # Ajusta según tu lógica de emparejamiento
	game_logic.connect("game_over", Callable(self, "_on_game_over"))
	_cargar_siguiente_microjuego()

func _cargar_siguiente_microjuego():
	if microjuego_actual:
		microjuego_actual.queue_free()
		microjuego_actual = null

	if indice_actual >= microjuegos.size():
		# Ya no hay más microjuegos
		return

	var escena = load(microjuegos[indice_actual])
	microjuego_actual = escena.instantiate()
	add_child(microjuego_actual)
	# Conecta señales del microjuego para saber cuándo termina
	if microjuego_actual.has_signal("completado"):
		microjuego_actual.connect("completado", Callable(self, "_on_microjuego_completado"))
	if microjuego_actual.has_signal("fallado"):
		microjuego_actual.connect("fallado", Callable(self, "_on_microjuego_fallado"))

func _on_microjuego_completado():
	game_logic.registrar_microjuego_completado()
	indice_actual += 1
	_cargar_siguiente_microjuego()

func _on_microjuego_fallado():
	game_logic.perder_vida()
	indice_actual += 1
	_cargar_siguiente_microjuego()

func _on_game_over(ganador, es_empate):
	print("¡Juego terminado!")
	if es_empate:
		print("Hubo un empate.")
	else:
		print("Ganador: ", ganador)
	# Aquí puedes cargar la pantalla de resultados o finalizar la partida

# Si necesitas reiniciar la partida
func reiniciar_partida():
	indice_actual = 0
	game_logic.reset()
	_cargar_siguiente_microjuego()
