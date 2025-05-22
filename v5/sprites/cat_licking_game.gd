extends Node2D

# Referencias a los nodos de la escena
@onready var cat_sprite = $CatSprite
@onready var ui_label = $CanvasLayer/UI/Label
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

# Variables para el auto-reinicio
var auto_restart_timer = 3.0  # Tiempo en segundos antes del auto-reinicio
var current_restart_timer = 0.0
var is_auto_restart_active = false

func _ready():
	# Configuramos el estado inicial
	setup_game()
	
func setup_sprite_sizing():
	"""Configura un tamaño uniforme para todas las imágenes del gato"""
	# Definir el tamaño base que queremos para todas las imágenes
	var target_size = Vector2(256, 256)  # Puedes cambiar estos valores
	
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
	is_auto_restart_active = false
	current_restart_timer = 0.0
	
	# Configurar el sprite inicial (gato parado)
	cat_sprite.texture = preload("res://sprites/micro 12/cat_idle.jpg")
	
	# Configurar la interfaz
	ui_label.text = "Presiona y mantén ESPACIO para que el gato se lama"
	
	print("Minijuego iniciado - Estado: IDLE")

func _process(delta):
	"""Actualiza el juego cada frame"""
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
	# Detectar si se empieza a presionar la tecla
	if Input.is_action_just_pressed("lick_action") or Input.is_key_pressed(lick_key):
		start_licking()

func handle_licking_state(delta):
	"""Maneja el estado cuando el gato se está lamiendo"""
	# Verificar si la tecla sigue presionada
	if Input.is_key_pressed(lick_key):
		# Continuar el proceso de lamida
		current_lick_time += delta
		lick_timer += delta
		
		# Actualizar la animación de lamida (alternar entre dos sprites)
		animate_licking()
		
		# Actualizar interfaz con progreso
		var progress = (current_lick_time / lick_duration) * 100
		ui_label.text = "¡Sigue así! Progreso: %.1f%%" % progress
		
		# Verificar si completó el tiempo requerido
		if current_lick_time >= lick_duration:
			complete_licking_success()
	else:
		# La tecla se soltó antes de tiempo - fallar
		complete_licking_failed()

func handle_success_state():
	"""Maneja el estado de éxito"""
	if is_auto_restart_active:
		current_restart_timer += get_process_delta_time()
		if current_restart_timer >= auto_restart_timer:
			setup_game()
	
	# Permitir reinicio manual con R
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		setup_game()

func handle_failed_state():
	"""Maneja el estado de fallo"""
	if is_auto_restart_active:
		current_restart_timer += get_process_delta_time()
		if current_restart_timer >= auto_restart_timer:
			setup_game()
	
	# Permitir reinicio manual con R
	if Input.is_action_just_pressed("ui_cancel") or Input.is_key_pressed(KEY_R):
		setup_game()

func start_licking():
	"""Inicia el proceso de lamida"""
	current_state = GameState.LICKING
	current_lick_time = 0.0
	lick_timer = 0.0
	is_key_pressed = true
	
	# Cambiar al primer sprite de lamida
	cat_sprite.texture = preload("res://sprites/micro 12/cat_lick_1.webp")
	
	ui_label.text = "¡Mantén presionada la tecla!"
	print("Iniciando lamida - Estado: LICKING")

func animate_licking():
	"""Alterna entre los dos sprites de lamida para crear animación"""
	if lick_timer >= lick_animation_speed:
		# Alternar entre los dos sprites de lamida
		if cat_sprite.texture.resource_path.ends_with("cat_lick_1.png"):
			cat_sprite.texture = preload("res://sprites/micro 12/cat_lick_2.jpg")
		else:
			cat_sprite.texture = preload("res://sprites/micro 12/cat_lick_1.webp")
		
		lick_timer = 0.0

func complete_licking_success():
	"""Completa el minijuego exitosamente"""
	current_state = GameState.SUCCESS
	
	# Mostrar sprite de gato feliz
	cat_sprite.texture = preload("res://sprites/micro 12/cat_happy.jpg")
	
	# Actualizar interfaz
	ui_label.text = "¡Excelente! El gato está limpio y feliz - Presiona R para reiniciar"
	
	print("¡Éxito! - Estado: SUCCESS")
	
	# Iniciar temporizador para auto-reinicio
	start_auto_restart_timer()

func complete_licking_failed():
	"""Completa el minijuego con fallo"""
	current_state = GameState.FAILED
	
	# Mostrar sprite de gato enojado
	cat_sprite.texture = preload("res://sprites/micro 12/cat_angry.webp")
	
	# Actualizar interfaz
	ui_label.text = "¡Oh no! El gato se enojó - Presiona R para intentar de nuevo"
	
	print("Falló - Estado: FAILED")
	
	# Iniciar temporizador para auto-reinicio
	start_auto_restart_timer()

func start_auto_restart_timer():
	"""Inicia el temporizador para reinicio automático"""
	is_auto_restart_active = true
	current_restart_timer = 0.0

func show_game_completion_alert(success: bool):
	"""Función removida - ya no se usan alertas"""
	pass

func _on_alert_confirmed():
	"""Función removida - ya no se usan alertas"""
	pass

# Función auxiliar para configurar las acciones de entrada
func _input(event):
	"""Maneja eventos de entrada adicionales si es necesario"""
	# Esta función puede usarse para manejar inputs más complejos
	# Por ahora, el manejo principal está en _process()
	pass

# Funciones de depuración (opcionales)
func _on_debug_reset_pressed():
	"""Botón de debug para reiniciar el juego"""
	setup_game()

func _on_debug_success_pressed():
	"""Botón de debug para simular éxito"""
	complete_licking_success()

func _on_debug_fail_pressed():
	"""Botón de debug para simular fallo"""
	complete_licking_failed()
