extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado


# Variables de dificultad
var nivel_dificultad = 1
var time_limit = 3.0  # 🔧 Nivel 1 = 3 segundos

# Referencias a los nodos de la escena
@onready var cat_sprite = $CatSprite
@onready var ui_label = $UI/Label
@onready var label_controles = $UI/TextoControles  # Nuevo nodo para controles
@onready var game_timer = $GameTimer

# Estados del juego
enum GameState {
	IDLE,        # Gato parado esperando
	LICKING,     # Gato lamiéndose
	SUCCESS,     # Completó exitosamente
	FAILED,      # Falló al soltar la tecla
	GAME_OVER    # Minijuego terminado
}

# Variables de control del juego
var current_state = GameState.IDLE
var lick_duration = 0.5  # Tiempo que debe mantener presionada la tecla (en segundos)
var current_lick_time = 0.0
var lick_key = KEY_SPACE  # Tecla que debe mantener presionada
var is_key_pressed = false

# Variables para la animación de lamida
var lick_animation_speed = 0.3  # Velocidad de alternancia entre sprites de lamida
var lick_timer = 0.0
var current_time_limit = 0.0
var is_time_limit_active = false

# Variable para controlar si el juego ya terminó
var game_completed = false

# Timer para mostrar el mensaje final antes de la señal
var final_message_timer = 0.0
var final_message_duration = 0.3  # Tiempo reducido para transición más rápida (era 1.5)

# NUEVA VARIABLE: Control para emitir la señal solo una vez
var signal_emitted = false

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			time_limit = 3.0
		2:
			time_limit = 2.5
		3:
			time_limit = 2.0
		4:
			time_limit = 1.5
		5:
			time_limit = 1.2
		6:
			time_limit = 1.0
		7:
			time_limit = 0.8
		8:
			time_limit = 0.5

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo límite:", time_limit)

func _ready():
	# Configuramos el estado inicial
	setup_game()
	
func setup_sprite_sizing():
	"""Configura un tamaño uniforme para todas las imágenes del gato"""
	# Definir el tamaño base que queremos para todas las imágenes
	var target_size = Vector2(750, 750)  # Puedes cambiar estos valores
	
	# Aplicar el tamaño al sprite
	cat_sprite.scale = Vector2.ONE  # Resetear escala primero
	
	# Obtener el tamaño original de la textura actual
	if cat_sprite.texture:
		var original_size = cat_sprite.texture.get_size()
		# Calcular la escala necesaria para llegar al tamaño objetivo
		var scale_factor = Vector2(
			target_size.x / original_size.x,
			target_size.y / original_size.y
		)
		cat_sprite.scale = scale_factor
		print("Sprite configurado con escala: ", scale_factor)

func setup_game():
	"""Inicializa el juego en su estado base"""
	current_state = GameState.IDLE
	current_lick_time = 0.0
	is_key_pressed = false
	game_completed = false
	final_message_timer = 0.0
	signal_emitted = false  # RESETEAR el control de señal
	
	# Mostrar el label al reiniciar
	ui_label.visible = true
	label_controles.visible = true  # Mostrar controles
	
	# Configurar límite de tiempo
	current_time_limit = 0.0
	is_time_limit_active = true
	
	# Configurar el sprite inicial (gato parado)
	cat_sprite.texture = preload("res://Microjuegos/Matias/12_Lavarse con la lengua/Sprites/gato_stanby.png")
	
	# 🔧 ACTUALIZAR interfaz con tiempo según dificultad
	ui_label.text = "Manten ESPACIO por %.1f " % time_limit
	
	print("Minijuego iniciado - Estado: IDLE con límite de tiempo")
	
func _process(delta):
	"""Actualiza el juego cada frame"""
	# Si el juego ya terminó, emitir señal inmediatamente
	if game_completed and not signal_emitted:
		signal_emitted = true
		ui_label.visible = false
		label_controles.visible = false
	
	if current_state == GameState.SUCCESS:
		emit_signal("microjuego_superado")  # NUEVO
		call_deferred("emit_signal", "finished", true)
	else:
		emit_signal("microjuego_fallado")  # NUEVO
		call_deferred("emit_signal", "finished", false)

		
		print("Señal 'finished' emitida con resultado: ", current_state == GameState.SUCCESS)
		return
	
	# Si ya se emitió la señal, no hacer nada más
	if game_completed:
		return
		
	match current_state:
		GameState.IDLE:
			handle_idle_state()
		GameState.LICKING:
			handle_licking_state(delta)
		GameState.SUCCESS:
			handle_success_state()
		GameState.FAILED:
			handle_failed_state()

func handle_idle_state():
	"""Maneja el estado cuando el gato está parado"""
	# Si el límite de tiempo está activo, actualizarlo
	if is_time_limit_active:
		current_time_limit += get_process_delta_time()
		
		# Mostrar tiempo restante en la UI
		var time_remaining = time_limit - current_time_limit
		ui_label.text = "Manten ESPACIO por %.1f "  % time_remaining
		
		# Verificar si se acabó el tiempo PRIMERO
		if current_time_limit >= time_limit:
			is_time_limit_active = false  # Desactivar inmediatamente
			complete_licking_failed()
			return  # Salir inmediatamente sin verificar teclas
	
	# Solo verificar teclas si el límite de tiempo sigue activo
	if is_time_limit_active and (Input.is_action_just_pressed("lick_action") or Input.is_key_pressed(lick_key)):
		start_licking()

func handle_licking_state(delta):
	"""Maneja el estado cuando el gato se está lamiendo"""
	# Verificar si la tecla sigue presionada
	if Input.is_key_pressed(lick_key):
		# Continuar el proceso de lamida
		current_lick_time += delta
		lick_timer += delta
		
		
		# Actualizar interfaz con progreso
		var progress = (current_lick_time / lick_duration) * 100
		ui_label.text = "¡Sigue así!  %.1f%%" % progress
		
		# Verificar si completó el tiempo requerido
		if current_lick_time >= lick_duration:
			complete_licking_success()
	else:
		# La tecla se soltó antes de tiempo - fallar
		complete_licking_failed()

func handle_success_state():
	"""Maneja el estado de éxito"""
	# Solo permitir reinicio manual con R si se desea
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		setup_game()

func handle_failed_state():
	"""Maneja el estado de fallo"""
	# Solo permitir reinicio manual con R si se desea
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		setup_game()

func start_licking():
	"""Inicia el proceso de lamida"""
	current_state = GameState.LICKING
	current_lick_time = 0.0
	lick_timer = 0.0
	is_key_pressed = true
	is_time_limit_active = false  # Desactivar el límite de tiempo
	
	# Cambiar al primer sprite de lamida
	cat_sprite.texture = preload("res://Microjuegos/Matias/12_Lavarse con la lengua/Sprites/cat_lick.png")
	
	ui_label.text = "¡Mantén presionada la tecla!"
	print("Iniciando lamida - Estado: LICKING")

func complete_licking_success():
	"""Completa el minijuego exitosamente"""
	current_state = GameState.SUCCESS
	game_completed = true  # Marcar el juego como completado
	final_message_timer = 0.0  # Resetear el timer del mensaje final
	# Mostrar sprite de gato feliz
	cat_sprite.texture = preload("res://Microjuegos/Matias/12_Lavarse con la lengua/Sprites/gatofelix.png")
	
	# Mostrar mensaje de éxito
	ui_label.text = "¡Excelente! El gato está limpio y feliz"
	ui_label.visible = true  # Asegurar que sea visible
	
	print("¡Éxito! - Juego completado")

func complete_licking_failed():
	"""Completa el minijuego con fallo"""
	current_state = GameState.FAILED
	game_completed = true  # Marcar el juego como completado
	is_time_limit_active = false
	final_message_timer = 0.0  # Resetear el timer del mensaje final
	
	# Mostrar sprite de gato enojado
	cat_sprite.texture = preload("res://Microjuegos/Matias/12_Lavarse con la lengua/Sprites/cat_angry.png")
	
	# Mostrar mensaje de fallo
	ui_label.text = "¡Oh no! El gato se enojó"
	ui_label.visible = true  # Asegurar que sea visible
	
	print("Falló - Juego completado")
