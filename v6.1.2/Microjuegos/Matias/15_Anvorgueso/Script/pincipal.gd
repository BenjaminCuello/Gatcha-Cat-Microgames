extends Node2D

signal finished(victory: bool)

@onready var cat = $GameArea/Cat
@onready var hamburger = $GameArea/Hamburger
@onready var owner1 = $GameArea/Owner
@onready var cat_falling = $GameArea/CatFalling
@onready var cat_satisfied = $GameArea/CatSatisfied
@onready var bar_fill = $UIContainer/GripBar/BarFill
@onready var grip_bar = $UIContainer/GripBar
@onready var instructions = $UIContainer/Instructions


# NUEVO: Referencias para el temporizador
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

# NUEVO: Variables del temporizador
var game_time = 3.0  # 3 segundos máximo
var current_time = 0.0
var max_time = 3.0

var shake_intensity = 0.0
var original_cat_position: Vector2
var original_owner_position: Vector2

func _ready():
	setup_game()
	
func setup_game():
	original_cat_position = cat.position
	original_owner_position = owner1.position
	
	# Ocultar sprites de animación al inicio
	cat_falling.visible = false
	cat_satisfied.visible = false
	
	# NUEVO: Configurar temporizador
	current_time = 0.0
	setup_timer_ui()
	
	instructions.text = "¡Mantén presionada la BARRA ESPACIADORA!\n¡Tienes 3 segundos!"
	instructions.modulate = Color.DARK_CYAN
	update_grip_bar()
	update_timer_display()
	
	await get_tree().create_timer(1.0).timeout
	start_game()

# NUEVO: Configurar la interfaz del temporizador
func setup_timer_ui():
	# Configurar el label del temporizador
	if timer_label:
		timer_label.text = "Tiempo: 3.0s"
		timer_label.add_theme_font_size_override("font_size", 24)
		timer_label.modulate = Color.WHITE
	
	# Configurar la barra de tiempo
	if timer_bar and timer_bar_fill:
		timer_bar_fill.color = Color.CYAN
		timer_bar_fill.size.x = timer_bar.size.x

func start_game():
	if game_finished:
		return
	game_started = true

func _process(delta):
	if not game_started or game_finished:
		return
	
	# NUEVO: Actualizar temporizador
	current_time += delta
	update_timer_display()
	
	# Verificar si se acabó el tiempo
	if current_time >= max_time:
		end_game_time_up()
		return
	
	# Detección mejorada de la barra espaciadora
	var space_pressed = false
	
	if not space_pressed:
		space_pressed = Input.is_key_pressed(KEY_SPACE)
	
	if space_pressed:
		grip_strength += grip_gain_rate * delta
		shake_intensity = 2.0
	else:
		grip_strength -= grip_decay_rate * delta
		shake_intensity = 5.0
	
	grip_strength = clamp(grip_strength, 0.0, 100.0)
	update_grip_bar()
	apply_shake_effect(delta)
	check_game_conditions()

# NUEVO: Actualizar visualización del temporizador
func update_timer_display():
	var remaining_time = max_time - current_time
	remaining_time = max(0.0, remaining_time)
	
	# Actualizar texto
	if timer_label:
		timer_label.text = "Tiempo: %.1fs" % remaining_time
		
		# Cambiar color según el tiempo restante
		if remaining_time <= 1.0:
			timer_label.modulate = Color.DARK_RED
		elif remaining_time <= 2.0:
			timer_label.modulate = Color.DARK_GOLDENROD
		else:
			timer_label.modulate = Color.WHITE
	
	# Actualizar barra de tiempo
	if timer_bar and timer_bar_fill:
		var time_percentage = remaining_time / max_time
		timer_bar_fill.size.x = timer_bar.size.x * time_percentage
		
		# Cambiar color de la barra según el tiempo
		if remaining_time <= 1.0:
			timer_bar_fill.color = Color.DARK_RED
		elif remaining_time <= 2.0:
			timer_bar_fill.color = Color.DARK_GOLDENROD
		else:
			timer_bar_fill.color = Color.DARK_CYAN

# NUEVO: Función para cuando se acaba el tiempo
func end_game_time_up():
	if game_finished:
		return
		
	game_finished = true
	game_started = false
	
	var victory = grip_strength >= victory_threshold
	
	if victory:
		instructions.text = "¡VICTORIA!\n¡Lograste aguantar hasta el final!"
		instructions.modulate = Color.DARK_GREEN
		animate_victory()
	else:
		instructions.text = "DERROTA\n¡Se acabó el tiempo!"
		instructions.modulate = Color.DARK_ORANGE
		animate_defeat()
	
	# Esperar a que termine la animación
	await get_tree().create_timer(2.0).timeout
	
	await get_tree().create_timer(0.5).timeout
	emit_signal("finished", victory)
	
func update_grip_bar():
	var fill_percentage = grip_strength / 100.0
	bar_fill.size.x = grip_bar.size.x * fill_percentage
	
	if grip_strength > 70:
		bar_fill.color = Color.GREEN
	elif grip_strength > 30:
		bar_fill.color = Color.DARK_GOLDENROD
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
		instructions.text = "¡VICTORIA!\n¡El gato logró comerse la hamburguesa!"
		instructions.modulate = Color.DARK_GREEN
		animate_victory()
	else:
		instructions.text = "DERROTA\nEl gato se cayó..."
		instructions.modulate = Color.FIREBRICK
		animate_defeat()
	
	# Esperar a que termine la animación
	await get_tree().create_timer(2.0).timeout
	
	await get_tree().create_timer(0.5).timeout
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
