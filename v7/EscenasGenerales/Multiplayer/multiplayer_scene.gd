extends Node

@onready var game_logic := preload("res://EscenasGenerales/Controladores/MultiplayerGame.gd").new()

var microjuegos = [
	"res://Microjuegos/Andres/26_Atrapa el ratón/Escena/atrapar_raton.tscn",
	"res://Microjuegos/Andres/27_Llamar al gato/Escena/llamarAlGato.tscn",
	"res://Microjuegos/Branco/6_Pesca en hielo/Escena/6_Pesca_Hielo.tscn",
	"res://Microjuegos/Branco/7_Recrear foto/Escena/7_Recrear_Foto.tscn",
	"res://Microjuegos/Branco/8_Surfeando/Escena/8_Surfeando.tscn",
	"res://Microjuegos/Branco/9_Flappy Birds con gatitos/Escena/9_Flappy_cat.tscn",
	# 🔧 AGREGAR: Tus microjuegos actualizados
	"res://Microjuegos/Matias/14_Gato laser/Escena/14_gato laser.tscn",
	"res://Microjuegos/Matias/15_Anvorgueso/Escena/Pincipal.tscn",
	# Agrega aquí las rutas correctas de tus microjuegos
]

func _ready():
	add_child(game_logic)
	game_logic.match_id = Global.match_id
	game_logic.oponente = Global.oponente
	
	# 🔧 CORREGIDO: Usar la nueva sintaxis de conexión
	game_logic.game_over.connect(_on_game_over)

	print("MultiplayerScene lista. Jugador contra: ", Global.oponente)
	_iniciar_microjuego()

func _iniciar_microjuego():
	var ruta = microjuegos.pick_random()
	
	# 🔧 CORREGIDO: Verificar que el archivo existe
	if not ResourceLoader.exists(ruta):
		print("Error: Microjuego no encontrado: ", ruta)
		return
	
	var escena_resource = load(ruta)
	if escena_resource == null:
		print("Error: No se pudo cargar: ", ruta)
		return
		
	var escena = escena_resource.instantiate()

	# 🔧 CORREGIDO: Conectar señales según el tipo de microjuego
	# Algunos usan "finished", otros usan señales específicas
	if escena.has_signal("finished"):
		escena.finished.connect(_on_microjuego_finished)
	elif escena.has_signal("microjuego_superado"):
		escena.microjuego_superado.connect(_on_microjuego_superado)
		escena.microjuego_fallado.connect(_on_microjuego_fallado)

	add_child(escena)

# 🔧 NUEVO: Manejar la señal "finished" estándar
func _on_microjuego_finished(success: bool):
	if success:
		game_logic.on_microjuego_superado()
	else:
		game_logic.on_microjuego_fallado()
	
	# Esperar un poco antes del siguiente microjuego
	await get_tree().create_timer(2.0).timeout
	
	# Limpiar microjuego anterior
	for child in get_children():
		if child != game_logic:
			child.queue_free()
	
	# Iniciar siguiente microjuego si el juego sigue activo
	if game_logic.vidas > 0:
		_iniciar_microjuego()

# 🔧 MANTENER: Para microjuegos con señales específicas
func _on_microjuego_superado():
	game_logic.on_microjuego_superado()

func _on_microjuego_fallado():
	game_logic.on_microjuego_fallado()

func _on_game_over(winner: String):
	print("Fin del juego. Ganador: ", winner)
	# 🔧 TODO: Cargar escena de resultados
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
