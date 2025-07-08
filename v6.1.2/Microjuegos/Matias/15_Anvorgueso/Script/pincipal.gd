extends Node2D
signal microjuego_superado
signal microjuego_fallado


signal finished(victory: bool)

# Variables de dificultad
var nivel_dificultad = 1
var game_time = 3.0  # Tiempo según dificultad
var max_time = 3.0   # Tiempo máximo según dificultad
var modo_mantener_espacio = true  # 🔧 NUEVO: true = mantener espacio, false = NO presionar

@onready var cat = $GameArea/Cat
@onready var hamburger = $GameArea/Hamburger
@onready var owner1 = $GameArea/Owner
@onready var cat_falling = $GameArea/CatFalling
@onready var cat_satisfied = $GameArea/CatSatisfied
@onready var bar_fill = $UIContainer/GripBar/BarFill
@onready var grip_bar = $UIContainer/GripBar
@onready var instructions = $UIContainer/Instructions

# Referencias para el temporizador
@onready var timer_label = $UIContainer/TimerLabel
@onready var timer_bar = $UIContainer/TimerBar
@onready var timer_bar_fill = $UIContainer/TimerBar/TimerBarFill

var game_started = false
var game_finished = false
var grip_strength = 50.0
var grip_decay_rate = 25.0
var grip_gain_rate = 40.0
var victory_threshold = 95.0
var defeat_threshold = 5.0

# Variables del temporizador
var current_time = 0.0

var shake_intensity = 0.0
var original_cat_position: Vector2
var original_owner_position: Vector2

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			game_time = 3.0
			max_time = 3.0
			modo_mantener_espacio = true  # Mantener espacio
		2:
			game_time = 3.0
			max_time = 3.0
			modo_mantener_espacio = false  # NO presionar nada
		3:
			game_time = 2.5
			max_time = 2.5
			modo_mantener_espacio = true  # Mantener espacio
		4:
			game_time = 2.5
			max_time = 2.5
			modo_mantener_espacio = false  # NO presionar nada
		5:
			game_time = 2.0
			max_time = 2.0
			modo_mantener_espacio = true  # Mantener espacio
		6:
			game_time = 2.0
			max_time = 2.0
			modo_mantener_espacio = false  # NO presionar nada
		7:
			game_time = 1.5
			max_time = 1.5
			modo_mantener_espacio = true  # Mantener espacio
		8:
			game_time = 1.5
			max_time = 1.5
			modo_mantener_espacio = false  # NO presionar nada

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo requerido:", game_time, "segundos")
	print("Modo:", "MANTENER ESPACIO" if modo_mantener_espacio else "NO PRESIONAR NADA")

func _ready():
	setup_game()
	
func setup_game():
	original_cat_position = cat.position
	original_owner_position = owner1.position
	
	# Ocultar sprites de animación al inicio
	cat_falling.visible = false
	cat_satisfied.visible = false
	
	# Configurar temporizador
	current_time = 0.0
	setup_timer_ui()
	
	# 🔧 NUEVO: Instrucciones según el modo
	if modo_mantener_espacio:
		instructions.text = "¡Mantén presionada la BARRA ESPACIADORA!\n¡Tienes %.1f segundos!" % game_time
		instructions.modulate = Color.DARK_CYAN
	else:
		instructions.text = "¡NO PRESIONES NADA!\n¡El gato debe resistir %.1f segundos!" % game_time
		instructions.modulate = Color.DARK_RED
	
	update_grip_bar()
	update_timer_display()
	
	await get_tree().create_timer(1.0).timeout
	start_game()

# Configurar la interfaz del temporizador
func setup_timer_ui():
	# Configurar el label del temporizador
	if timer_label:
		timer_label.text = "Tiempo: %.1fs" % game_time
		timer_label.add_theme_font_size_override("font_size", 24)
		timer_label.modulate = Color.WHITE
	
	# Configurar la barra de tiempo
	if timer_bar and timer_bar_fill:
		# 🔧 NUEVO: Color según el modo
		if modo_mantener_espacio:
			timer_bar_fill.color = Color.CYAN
		else:
			timer_bar_fill.color = Color.ORANGE
		timer_bar_fill.size.x = timer_bar.size.x

func start_game():
	if game_finished:
		return
	game_started = true

func _process(delta):
	if not game_started or game_finished:
		return
	
	# Actualizar temporizador
	current_time += delta
	update_timer_display()
	
	# Verificar si se acabó el tiempo
	if current_time >= max_time:
		end_game_time_up()
		return
	
	# 🔧 NUEVO: Lógica según el modo
	var space_pressed = Input.is_key_pressed(KEY_SPACE)
	
	if modo_mantener_espacio:
		# Modo original: mantener espacio
		if space_pressed:
			grip_strength += grip_gain_rate * delta
			shake_intensity = 2.0
		else:
			grip_strength -= grip_decay_rate * delta
			shake_intensity = 5.0
	else:
		# Modo nuevo: NO presionar nada
		if space_pressed:
			# Si presiona espacio, pierde grip
			grip_strength -= grip_decay_rate * delta * 1.5  # Penalización extra
			shake_intensity = 8.0  # Shake más intenso
		else:
			# Si NO presiona, gana grip
			grip_strength += grip_gain_rate * delta
			shake_intensity = 1.0  # Shake mínimo
	
	grip_strength = clamp(grip_strength, 0.0, 100.0)
	update_grip_bar()
	apply_shake_effect(delta)
	check_game_conditions()

# Actualizar visualización del temporizador
func update_timer_display():
	var remaining_time = max_time - current_time
	remaining_time = max(0.0, remaining_time)
	
	# Actualizar texto
	if timer_label:
		timer_label.text = "Tiempo: %.1fs" % remaining_time
		
		# Cambiar color según el tiempo restante
		if remaining_time <= 0.5:
			timer_label.modulate = Color.DARK_RED
		elif remaining_time <= 1.0:
			timer_label.modulate = Color.DARK_GOLDENROD
		else:
			timer_label.modulate = Color.WHITE
	
	# Actualizar barra de tiempo
	if timer_bar and timer_bar_fill:
		var time_percentage = remaining_time / max_time
		timer_bar_fill.size.x = timer_bar.size.x * time_percentage
		
		# 🔧 NUEVO: Color según el modo y tiempo restante
		if modo_mantener_espacio:
			if remaining_time <= 0.5:
				timer_bar_fill.color = Color.DARK_RED
			elif remaining_time <= 1.0:
				timer_bar_fill.color = Color.DARK_GOLDENROD
			else:
				timer_bar_fill.color = Color.DARK_CYAN
		else:
			if remaining_time <= 0.5:
				timer_bar_fill.color = Color.DARK_RED
			elif remaining_time <= 1.0:
				timer_bar_fill.color = Color.DARK_GOLDENROD
			else:
				timer_bar_fill.color = Color.DARK_ORANGE

# Función para cuando se acaba el tiempo
func end_game_time_up():
	if game_finished:
		return
		
	game_finished = true
	game_started = false
	
	var victory = grip_strength >= victory_threshold
	
	if victory:
		if modo_mantener_espacio:
			instructions.text = "¡VICTORIA!\n¡Lograste mantener la hamburguesa!"
		else:
			instructions.text = "¡VICTORIA!\n¡El gato resistió la tentación!"
		instructions.modulate = Color.DARK_GREEN
		animate_victory()
	else:
		if modo_mantener_espacio:
			instructions.text = "DERROTA\n¡No pudiste mantener la hamburguesa!"
		else:
			instructions.text = "DERROTA\n¡El gato no pudo resistir!"
		instructions.modulate = Color.DARK_ORANGE
		animate_defeat()
	
	# Esperar a que termine la animación
	await get_tree().create_timer(2.0).timeout
	
	await get_tree().create_timer(0.5).timeout
	emit_signal("finished", victory)
	
func update_grip_bar():
	var fill_percentage = grip_strength / 100.0
	bar_fill.size.x = grip_bar.size.x * fill_percentage
	
	# 🔧 NUEVO: Colores según el modo
	if modo_mantener_espacio:
		# Modo mantener: verde = bueno
		if grip_strength > 70:
			bar_fill.color = Color.GREEN
		elif grip_strength > 30:
			bar_fill.color = Color.DARK_GOLDENROD
		else:
			bar_fill.color = Color.DARK_RED
	else:
		# Modo resistir: azul = resistencia
		if grip_strength > 70:
			bar_fill.color = Color.BLUE
		elif grip_strength > 30:
			bar_fill.color = Color.PURPLE
		else:
			bar_fill.color = Color.DARK_RED

func apply_shake_effect(delta):
	if shake_intensity > 0:
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		
		cat.position = original_cat_position + shake_offset
		owner1.position = original_owner_position + shake_offset * 0.5
		shake_intensity = lerp(shake_intensity, 0.0, delta * 3.0)

func check_game_conditions():
	# Solo verificar victoria/derrota por grip, no por tiempo aquí
	if grip_strength >= victory_threshold:
		end_game(true)
	elif grip_strength <= defeat_threshold:
		end_game(false)

func end_game(victory: bool):
	if game_finished:
		return
		
	game_finished = true
	game_started = false
	
	if victory:
		if modo_mantener_espacio:
			instructions.text = "¡VICTORIA!\n¡El gato logró comerse la hamburguesa!"
		else:
			instructions.text = "¡VICTORIA!\n¡El gato resistió la tentación!"
		instructions.modulate = Color.DARK_GREEN
		animate_victory()
	else:
		if modo_mantener_espacio:
			instructions.text = "DERROTA\n¡El gato perdió la hamburguesa!"
		else:
			instructions.text = "DERROTA\n¡El gato no pudo resistir!"
		instructions.modulate = Color.FIREBRICK
		animate_defeat()
	
	# Esperar a que termine la animación
	await get_tree().create_timer(2.0).timeout
	await get_tree().create_timer(0.5).timeout

	if victory:
		emit_signal("microjuego_superado")
	else:
		emit_signal("microjuego_fallado")

	emit_signal("finished", victory)


func animate_victory():
	# Ocultar gato original y hamburguesa
	cat.visible = false
	hamburger.visible = false
	
	# Mostrar gato satisfecho en la posición de la hamburguesa
	cat_satisfied.position = hamburger.position
	cat_satisfied.visible = true
	
	# Animación de satisfacción (pequeño rebote)
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(cat_satisfied, "scale", Vector2(0.5, 0.5), 0.2)
	tween.tween_property(cat_satisfied, "scale", Vector2(0.7, 0.7), 0.2)

func animate_defeat():
	# Ocultar gato original
	cat.visible = false
	
	# Posicionar gato cayendo en la posición original del gato
	cat_falling.position = original_cat_position
	cat_falling.visible = true
	
	# Animación estilo Mario Bros: caída con rotación
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Caída (movimiento parabólico)
	tween.tween_method(_animate_falling_arc, 0.0, 1.0, 2.0)
	
	# Rotación mientras cae
	tween.tween_property(cat_falling, "rotation", randf_range(4.0, 8.0), 2.0)
	
	# Desvanecimiento al final
	tween.tween_property(cat_falling, "modulate:a", 0.0, 0.5).set_delay(1.5)

func _animate_falling_arc(progress: float):
	var start_pos = original_cat_position
	var end_x = start_pos.x + randf_range(-100, 100)
	var screen_height = get_viewport().get_visible_rect().size.y
	
	var current_x = lerp(start_pos.x, end_x, progress)
	var arc_height = -50
	var current_y = start_pos.y + arc_height * sin(progress * PI) + (screen_height + 100) * (progress * progress)
	
	cat_falling.position = Vector2(current_x, current_y)
