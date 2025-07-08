extends Node

@onready var game_logic = preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()
@onready var pantalla_espera = $PantallaEspera

var lista_microjuegos = [
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
	"res://Microjuegos/Matias/13_Cortarle el pelo/Escena/13_cortarPelo.tscn",
	"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	"res://Microjuegos/Matias/15_Anvorgueso/Escena/Pincipal.tscn",
	"res://Microjuegos/Ramiro/21_¡Abrelatas!/Escena/Abrelatas (3).tscn",
	"res://Microjuegos/Ramiro/22_Atrápalo/Escena/Atrapalo (6).tscn"
]

var microjuegos_jugados := []
var indice_actual := 0
var microjuego_actual: Node = null
var juego_terminado := false

var jugador_termino := false
var oponente_termino := false

func _ready():
	add_child(game_logic)
	game_logic.total_microjuegos = lista_microjuegos.size()
	game_logic.oponente = "Oponente"
	game_logic.connect("game_over", Callable(self, "_on_game_over"))
	pantalla_espera.visible = false
	cargar_siguiente_microjuego()

func cargar_siguiente_microjuego():
	if juego_terminado:
		return

	if microjuego_actual:
		microjuego_actual.queue_free()
		microjuego_actual = null

	var disponibles = []
	for microjuego in lista_microjuegos:
		if not microjuego in microjuegos_jugados:
			disponibles.append(microjuego)

	if disponibles.size() == 0 or game_logic.terminado:
		print("¡Todos los microjuegos jugados o el juego terminó!")
		return

	var siguiente = disponibles.pick_random()
	if not ResourceLoader.exists(siguiente):
		print("ERROR: El archivo no existe: ", siguiente)
		return

	var escena = load(siguiente)
	microjuego_actual = escena.instantiate()
	add_child(microjuego_actual)
	microjuegos_jugados.append(siguiente)
	indice_actual += 1

	jugador_termino = false
	oponente_termino = false
	pantalla_espera.visible = false

	if microjuego_actual.has_signal("completado"):
		microjuego_actual.connect("completado", Callable(self, "_on_microjuego_completado"))
	if microjuego_actual.has_signal("fallado"):
		microjuego_actual.connect("fallado", Callable(self, "_on_microjuego_fallado"))

func _on_microjuego_completado():
	if juego_terminado or jugador_termino:
		return
	jugador_termino = true
	rpc("notificar_terminado")
	chequear_transicion_microjuego()
	game_logic.registrar_microjuego_completado()

func _on_microjuego_fallado():
	if juego_terminado or jugador_termino:
		return
	jugador_termino = true
	rpc("notificar_terminado")
	chequear_transicion_microjuego()
	game_logic.perder_vida()

@rpc("any_peer")
func notificar_terminado():
	oponente_termino = true
	chequear_transicion_microjuego()

func chequear_transicion_microjuego():
	if jugador_termino and not oponente_termino:
		pantalla_espera.visible = true
	elif jugador_termino and oponente_termino:
		pantalla_espera.visible = false
		await get_tree().create_timer(1.0).timeout
		cargar_siguiente_microjuego()

func _on_game_over(ganador, es_empate):
	juego_terminado = true
	if microjuego_actual:
		microjuego_actual.queue_free()
		microjuego_actual = null
	pantalla_espera.visible = false
	print("¡Juego terminado!")
	if es_empate:
		print("Hubo un empate.")
	else:
		print("Ganador: ", ganador)

func reiniciar_partida():
	indice_actual = 0
	microjuegos_jugados.clear()
	juego_terminado = false
	game_logic.reset()
	cargar_siguiente_microjuego()
