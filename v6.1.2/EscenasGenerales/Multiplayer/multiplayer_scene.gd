extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()
var contador_microjuegos := 1  # Se incrementa después de cada microjuego

var microjuegos = [
	"res://Microjuegos/Andres/26_Atrapa el ratón/Escena/atrapar_raton.tscn",
	"res://Microjuegos/Andres/27_Llamar al gato/Escena/llamarAlGato.tscn",
	"res://Microjuegos/Branco/6_Pesca en hielo/Escena/6_Pesca_Hielo.tscn",
	"res://Microjuegos/Branco/7_Recrear foto/Escena/7_Recrear_Foto.tscn",
	"res://Microjuegos/Branco/8_Surfeando/Escena/8_Surfeando.tscn",
	"res://Microjuegos/Branco/9_Flappy Birds con gatitos/Escena/9_Flappy_cat.tscn",
	"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	"res://Microjuegos/Matias/15_Anvorgueso/Escena/Principal.tscn",
]

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	
	game_logic.game_over.connect(_on_game_over)

	print("MultiplayerScene lista. Jugador contra: ", Global.oponente)
	_iniciar_microjuego()

func _iniciar_microjuego():
	var ruta = microjuegos.pick_random()

	if not ResourceLoader.exists(ruta):
		print("Error: Microjuego no encontrado: ", ruta)
		return

	var escena_resource = load(ruta)
	if escena_resource == null:
		print("Error: No se pudo cargar: ", ruta)
		return

	var escena = escena_resource.instantiate()

	# 🔧 NUEVO: Aplicar dificultad extra si corresponde
	if game_logic.dificultad_extra != "":
		if escena.has_method("aplicar_dificultad"):
			escena.aplicar_dificultad(game_logic.dificultad_extra)
			print("⚠️ Dificultad extra aplicada:", game_logic.dificultad_extra)
		else:
			print("⚠️ El microjuego no implementa aplicar_dificultad()")
		game_logic.dificultad_extra = ""  # Resetear después de aplicar

	# 🔧 CONECTAR señales según el tipo
	if escena.has_signal("finished"):
		escena.finished.connect(_on_microjuego_finished)
	elif escena.has_signal("microjuego_superado"):
		escena.microjuego_superado.connect(_on_microjuego_superado)
		escena.microjuego_fallado.connect(_on_microjuego_fallado)

	add_child(escena)

func _on_microjuego_finished(success: bool):
	if success:
		game_logic.on_microjuego_superado()
	else:
		game_logic.on_microjuego_fallado()

	await get_tree().create_timer(2.0).timeout

	for child in get_children():
		if child != game_logic:
			child.queue_free()

	if game_logic.vidas > 0:
		# Instanciar contador online como escena intermedia
		var contador = preload("res://EscenasGenerales/EscenaVidasNumeroMicrojuego/ContadorVidasOnline.tscn").instantiate()
		contador.microjuego_actual = contador_microjuegos  # opcional si exportado
		get_tree().root.add_child(contador)
		
		# Importante: liberar escena actual para que no quede encima
		get_tree().current_scene.queue_free()



func _on_microjuego_superado():
	game_logic.on_microjuego_superado()

func _on_microjuego_fallado():
	game_logic.on_microjuego_fallado()

func _on_game_over(winner: String):
	print("Fin del juego. Ganador: ", winner)

	var escena_resultado = preload("res://EscenasGenerales/Menus/Online/escena_resultado.tscn").instantiate()
	escena_resultado.ganador = winner
	escena_resultado.victoria = (winner == Global.username)

func _iniciar_microjuego_real():
	var ruta = microjuegos.pick_random()

	if not ResourceLoader.exists(ruta):
		print("Error: Microjuego no encontrado: ", ruta)
		return

	var escena_resource = load(ruta)
	if escena_resource == null:
		print("Error: No se pudo cargar: ", ruta)
		return

	var escena = escena_resource.instantiate()

	# Aplicar dificultad si corresponde
	if game_logic.dificultad_extra != "":
		if escena.has_method("aplicar_dificultad"):
			escena.aplicar_dificultad(game_logic.dificultad_extra)
			print("⚠️ Dificultad extra aplicada:", game_logic.dificultad_extra)
		else:
			print("⚠️ El microjuego no implementa aplicar_dificultad()")
		game_logic.dificultad_extra = ""

	# Conectar señales
	if escena.has_signal("finished"):
		escena.finished.connect(_on_microjuego_finished)
	elif escena.has_signal("microjuego_superado"):
		escena.microjuego_superado.connect(_on_microjuego_superado)
		escena.microjuego_fallado.connect(_on_microjuego_fallado)

	add_child(escena)
	var escena_resultado = load("res://EscenasGenerales/EscenaVictoriaDerrota/escena_resultado.tscn").instantiate()

	get_tree().root.add_child(escena_resultado)
	get_tree().current_scene.queue_free()  # Opcional: elimina la escena actual
