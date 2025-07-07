extends Node2D

signal finished(victory: bool)

@onready var cat = $GameArea/Cat
@onready var hamburger = $GameArea/Hamburger
@onready var owner1 = $GameArea/Owner
@onready var cat_falling = $GameArea/CatFalling  # NUEVO
@onready var cat_satisfied = $GameArea/CatSatisfied  # NUEVO
@onready var bar_fill = $UIContainer/GripBar/BarFill
@onready var grip_bar = $UIContainer/GripBar
@onready var instructions = $UIContainer/Instructions
@onready var game_over_screen = $UIContainer/GameOverScreen
@onready var result_label = $UIContainer/GameOverScreen/ResultLabel

var game_started = false
var game_finished = false
var grip_strength = 50.0
var grip_decay_rate = 25.0
var grip_gain_rate = 40.0
var victory_threshold = 95.0
var defeat_threshold = 5.0

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
	
	instructions.text = "¡Mantén presionada la BARRA ESPACIADORA!"
	game_over_screen.visible = false
	update_grip_bar()
	
	await get_tree().create_timer(1.0).timeout
	start_game()

func start_game():
	if game_finished:
		return
	game_started = true

func _process(delta):
	if not game_started or game_finished:
		return
	
	if Input.is_action_pressed("grip"):
		grip_strength += grip_gain_rate * delta
		shake_intensity = 2.0
	else:
		grip_strength -= grip_decay_rate * delta
		shake_intensity = 5.0
	
	grip_strength = clamp(grip_strength, 0.0, 100.0)
	update_grip_bar()
	apply_shake_effect(delta)
	check_game_conditions()

func update_grip_bar():
	var fill_percentage = grip_strength / 100.0
	bar_fill.size.x = grip_bar.size.x * fill_percentage
	
	if grip_strength > 70:
		bar_fill.color = Color.GREEN
	elif grip_strength > 30:
		bar_fill.color = Color.YELLOW
	else:
		bar_fill.color = Color.RED

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
		result_label.text = "¡VICTORIA!\n¡El gato logró comerse la hamburguesa!"
		result_label.modulate = Color.GREEN
		animate_victory()
	else:
		result_label.text = "DERROTA\nEl gato se cayó..."
		result_label.modulate = Color.RED
		animate_defeat()
	
	# Esperar a que termine la animación antes de mostrar resultado
	await get_tree().create_timer(2.0).timeout
	game_over_screen.visible = true
	
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
	tween.set_parallel(true)  # Permite múltiples animaciones simultáneas
	
	# Caída (movimiento parabólico)
	tween.tween_method(_animate_falling_arc, 0.0, 1.0, 2.0)
	
	# Rotación mientras cae
	tween.tween_property(cat_falling, "rotation", randf_range(4.0, 8.0), 2.0)
	
	# Desvanecimiento al final
	tween.tween_property(cat_falling, "modulate:a", 0.0, 0.5).set_delay(1.5)

func _animate_falling_arc(progress: float):
	# Crear una trayectoria parabólica de caída
	var start_pos = original_cat_position
	var end_x = start_pos.x + randf_range(-100, 100)  # Desplazamiento horizontal aleatorio
	var screen_height = get_viewport().get_visible_rect().size.y
	
	# Posición X: interpolación lineal
	var current_x = lerp(start_pos.x, end_x, progress)
	
	# Posición Y: parábola que simula gravedad
	# Primero sube un poco, luego cae aceleradamente
	var arc_height = -50  # Altura del "salto" inicial
	var current_y = start_pos.y + arc_height * sin(progress * PI) + (screen_height + 100) * (progress * progress)
	
	cat_falling.position = Vector2(current_x, current_y)
