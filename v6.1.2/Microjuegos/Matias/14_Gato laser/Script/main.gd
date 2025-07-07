extends Node2D

signal finished(victory: bool)

@onready var cat = $Cat
@onready var laser = $Laser
@onready var game_timer = $GameTimer
@onready var time_label = $TimeLabel
@onready var instruction_label = $InstructionLabel

var game_duration = 5.0
var laser_contact_time = 0.0
var max_laser_contact = 3.0
var game_active = true
var nivel_dificultad := 1

# Configurar dificultad del microjuego
func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	game_duration = Juego.obtener_duracion_por_dificultad(nivel)
	print("🎯 Gato láser configurado con dificultad ", nivel, " - Duración: ", game_duration, "s")

# Método alternativo para configurar duración directamente
func set_duracion_juego(duracion: float):
	game_duration = duracion
	print("⏱️ Duración del Gato láser configurada: ", duracion, "s")

# Sistema de proximidad sensible
var proximity_threshold_close = 100.0
var proximity_threshold_very_close = 50.0
var base_contact_rate = 1.0
var close_contact_rate = 2.0
var very_close_contact_rate = 4.0

# Variable para el efecto de parpadeo
var blink_timer = 0.0

func _ready():
	# Verificar que todos los nodos existen
	if not cat:
		print("Error: No se encontró el nodo Cat")
		return
	if not laser:
		print("Error: No se encontró el nodo Laser")
		return
	if not game_timer:
		print("Error: No se encontró el nodo GameTimer")
		return
	if not time_label:
		print("Error: No se encontró el nodo TimeLabel")
		return
	if not instruction_label:
		print("Error: No se encontró el nodo InstructionLabel")
		return
	
	# Inicializar el juego
	reset_game()

func reset_game():
	"""Función para resetear completamente el juego"""
	game_active = true
	laser_contact_time = 0.0
	blink_timer = 0.0
	
	# Resetear timer
	game_timer.wait_time = game_duration
	if game_timer.timeout.is_connected(_on_game_timeout):
		game_timer.timeout.disconnect(_on_game_timeout)
	game_timer.timeout.connect(_on_game_timeout)
	game_timer.start()
	
	# Configurar UI inicial
	instruction_label.text = "¡Evita que el gato toque el láser!"
	instruction_label.add_theme_font_size_override("font_size", 64)
	instruction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instruction_label.modulate = Color.WHITE
	
	# Resetear posiciones
	cat.global_position = Vector2(100, 100)
	
	# Colocar el láser en el centro de la pantalla
	var screen_center = get_viewport().get_visible_rect().size / 2
	laser.global_position = screen_center
	
	# Resetear el gato y el láser
	if cat.has_method("reset_cat"):
		cat.reset_cat()
	if laser.has_method("stop_movement"):
		laser.stop_movement()

func _process(delta):
	if not game_active:
		return
		
	time_label.text = "Tiempo: " + str(int(game_timer.time_left))
	
	# Sistema de proximidad sensible
	check_laser_contact_with_proximity(delta)

func check_laser_contact_with_proximity(delta):
	if not game_active:
		return
		
	# Calcular distancia entre gato y láser
	var distance = cat.global_position.distance_to(laser.global_position)
	
	# Verificar contacto directo
	var laser_areas = laser.get_overlapping_areas()
	var cat_touching = false
	
	for area in laser_areas:
		if area.get_parent() == cat:
			cat_touching = true
			break
	
	# Determinar velocidad del contador según proximidad
	var contact_rate = 0.0
	var proximity_status = ""
	var warning_color = Color.WHITE
	
	if cat_touching:
		contact_rate = very_close_contact_rate * 2
		proximity_status = "¡CONTACTO DIRECTO!"
		warning_color = Color.RED
	elif distance <= proximity_threshold_very_close:
		contact_rate = very_close_contact_rate
		proximity_status = "¡MUY CERCA!"
		warning_color = Color.ORANGE_RED
	elif distance <= proximity_threshold_close:
		contact_rate = close_contact_rate
		proximity_status = "¡CERCA!"
		warning_color = Color.YELLOW
	
	# Aplicar contador solo si hay proximidad
	if contact_rate > 0:
		laser_contact_time += delta * contact_rate
		
		# Mostrar advertencia con tiempo restante
		var time_remaining = max_laser_contact - laser_contact_time
		if time_remaining > 0:
			instruction_label.text = proximity_status + " Tiempo: " + str("%.1f" % time_remaining)
			instruction_label.modulate = warning_color
			
			# Parpadeo crítico
			if time_remaining < 1.0:
				blink_timer += delta
				var blink = int(blink_timer / 0.15) % 2 == 0
				instruction_label.modulate = Color.RED if blink else Color.WHITE
		
		# Verificar derrota
		if laser_contact_time >= max_laser_contact:
			end_game(false)
	else:
		# Resetear cuando está lejos
		laser_contact_time = 0.0
		blink_timer = 0.0
		instruction_label.text = "¡Evita que el gato toque el láser!"
		instruction_label.modulate = Color.WHITE

func _on_game_timeout():
	end_game(true)

func end_game(victory: bool):
	if not game_active:
		return
		
	game_active = false
	game_timer.stop()
	
	# Detener completamente el movimiento del gato y el láser
	if cat.has_method("stop_movement"):
		cat.stop_movement()
	if laser.has_method("stop_movement"):
		laser.stop_movement()
	
	# Mostrar resultado
	if victory:
		instruction_label.text = "¡VICTORIA! Mantuviste al gato alejado"
		instruction_label.modulate = Color.GREEN
	else:
		instruction_label.text = "¡DERROTA! El gato se aburrió con el láser"
		instruction_label.modulate = Color.RED
	
	# Esperar un momento antes de emitir la señal
	await get_tree().create_timer(1.5).timeout
	emit_signal("finished", victory)

# Nueva función para ser llamada desde el sistema principal cuando se reinicia
func restart_microgame():
	reset_game()
