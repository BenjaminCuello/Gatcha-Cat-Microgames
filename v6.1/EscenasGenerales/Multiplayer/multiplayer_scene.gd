extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	game_logic.connect("game_over", Callable(self, "_on_game_over"))

	print("MultiplayerScene lista. Jugador contra: ", Global.oponente)
	_iniciar_microjuego()

func _iniciar_microjuego():
	# Aquí iría tu lógica de cargar un microjuego real
	# Cuando el jugador lo supere, llamas a:
	# game_logic.on_microjuego_superado()
	# O si falla:
	# game_logic.on_microjuego_fallado()
	pass

func _on_game_over(winner: String):
	print("Fin del juego. Ganador: ", winner)
	# Aquí puedes cargar una escena de resultados o volver al menú
