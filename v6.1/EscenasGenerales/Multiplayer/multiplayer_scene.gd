extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

var microjuegos = [
	"res://Microjuegos/Andres/26_Atrapa el ratón/Escena/atrapar_raton.tscn",
	"res://Microjuegos/Andres/27_Llamar al gato/Escena/llamarAlGato.tscn",
	"res://Microjuegos/Branco/6_Pesca en hielo/Escena/6_Pesca_Hielo.tscn",
	"res://Microjuegos/Branco/7_Recrear foto/Escena/7_Recrear_Foto.tscn",
	"res://Microjuegos/Branco/8_Surfeando/Escena/8_Surfeando.tscn",
	"res://Microjuegos/Branco/9_Flappy Birds con gatitos/Escena/9_Flappy_cat.tscn",
	"res://Microjuegos/Branco/10_Juego de cartas/Escena/10_Cartas.tscn",
	"res://Microjuegos/Branco/Secreto1/Escena/28_Secreto1.tscn",
	"res://Microjuegos/Cuello/16_Tecla gatuna/Escena/Tecla gatuna (1).tscn",
	"res://Microjuegos/Cuello/18_Gato equilibrio/Escena/Gato equilibrio (2).tscn",
	"res://Microjuegos/Cuello/19_  Baile rítmico/Escena/Baile rítmico (5).tscn",
	"res://Microjuegos/Emily/1_Escondite en cajas/Escena/1_Escondite_gatuno.tscn",
	"res://Microjuegos/Emily/3_Apunta y dispara/Escena/main.tscn",
	"res://Microjuegos/Emily/4_Gato guatón/Escena/main.tscn",
	"res://Microjuegos/Emily/5_Encuentra al impostor/Escena/5_Encuentra_Impostor.tscn",
	"res://Microjuegos/Matias/11_Morder al muñeco/Escena/11_Morder_al_muñeco.tscn",
	"res://Microjuegos/Matias/12_Lavarse con la lengua/Escena/12_Gato Lamerse.tscn",
	#"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	#"res://Microjuegos/Matias/15_Anvorgueso/Escena/Pincipal.tscn",
	"res://Microjuegos/Ramiro/21_¡Abrelatas!/Escena/Abrelatas (3).tscn",
	"res://Microjuegos/Ramiro/22_Atrápalo/Escena/Atrapalo (6).tscn"
]

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	game_logic.connect("game_over", Callable(self, "_on_game_over"))

	print("MultiplayerScene lista. Jugador contra: ", Global.oponente)
	_iniciar_microjuego()

func _iniciar_microjuego():
	var ruta = microjuegos.pick_random()
	var escena = load(ruta).instantiate()

	# Conectar señales para saber si ganó o perdió
	escena.connect("microjuego_superado", Callable(game_logic, "on_microjuego_superado"))
	escena.connect("microjuego_fallado", Callable(game_logic, "on_microjuego_fallado"))

	add_child(escena)

func _on_game_over(winner: String):
	print("Fin del juego. Ganador: ", winner)
	# Aquí puedes cargar una escena de resultados o volver al menú
