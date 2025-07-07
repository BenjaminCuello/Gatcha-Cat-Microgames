extends Node2D
signal finished(success)

@onready var player = $Player
@onready var good_food = $GoodFood
@onready var bad_food = $BadFood
@onready var label = $Instruccion  # Label para mensaje principal
@onready var label_controles = $TextoControles  # Label para controles
@onready var timer = $TiempoRestante
@onready var time_bar = $barraDeTiempo

var screen_size
var base_fall_speed = 500  # Velocidad base de caída
var fall_speed
var food_limit_y = 1000
var jugando = true
var fall_count = 0
var max_falls = 2
@export var duracion_juego = 6.0  # Incrementado en 1 segundo
var player_speed = 1000  # Incrementado para mover más rápido

func _ready():
	randomize()
	duracion_juego = [5.0, 6.0].pick_random()  # Extender duración aleatoria
	screen_size = get_viewport_rect().size

	# Configurar velocidad inicial
	fall_speed = base_fall_speed

	# Configurar instrucciones
	label.text = "¡Come bien!"
	label.visible = true
	label_controles.text = "Usa ← → para moverte."
	label_controles.visible = true

	# Configurar barra de tiempo
	time_bar.max_value = duracion_juego
	time_bar.value = duracion_juego

	# Configurar timer
	timer.timeout.connect(_on_timer_timeout)
	timer.start(duracion_juego)

	# Conectar señales de colisión
	good_food.connect("body_entered", Callable(self, "_on_good_food_body_entered"))
	bad_food.connect("body_entered", Callable(self, "_on_bad_food_body_entered"))

	launch_food()

func _process(delta):
	if not jugando:
		return

	handle_player_input(delta)
	move_foods(delta)

	# Actualizar barra de tiempo
	if timer.time_left >= 0:
		time_bar.value = timer.time_left

	# Aumentar velocidad de caída si el tiempo restante es crítico
	if timer.time_left < duracion_juego / 2:  # Aumentar velocidad en mitad del tiempo
		fall_speed = base_fall_speed * 1.5
	elif timer.time_left < duracion_juego / 4:  # Aumentar más velocidad en el último cuarto
		fall_speed = base_fall_speed * 2

func handle_player_input(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	player.position.x += dir * player_speed * delta  # Incrementar velocidad
	player.position.x = clamp(player.position.x, 0, screen_size.x)

func move_foods(delta):
	if !good_food.visible:
		return

	# Mover comida
	good_food.position.y += fall_speed * delta
	bad_food.position.y += fall_speed * delta

	# Si la buena cae sin atraparse = derrota
	if good_food.position.y > food_limit_y:
		end_game(false, "¡Derrota!")

	# Si la basura cae sola, simplemente desaparece
	if bad_food.position.y > food_limit_y:
		bad_food.visible = false

func launch_food():
	if fall_count >= max_falls:
		end_game(true, "¡Victoria!")
		return

	var view_width = screen_size.x
	var margin = 100
	var good_x = randf_range(margin, view_width - margin)
	var bad_x = randf_range(margin, view_width - margin)

	while abs(good_x - bad_x) < 150:
		bad_x = randf_range(margin, view_width - margin)

	var spawn_y = -50
	good_food.position = Vector2(good_x, spawn_y)
	bad_food.position = Vector2(bad_x, spawn_y)

	good_food.visible = true
	bad_food.visible = true

	fall_count += 1

func _on_good_food_body_entered(body):
	if body == player and jugando:
		good_food.visible = false
		bad_food.visible = false
		await get_tree().create_timer(0.5).timeout
		launch_food()

func _on_bad_food_body_entered(body):
	if body == player and jugando:
		end_game(false, "Comiste basura")

func end_game(success, message):
	if not jugando:
		return
	jugando = false
	timer.stop()

	label.text = message
	label.visible = true
	label_controles.visible = false  # Ocultar controles
	good_food.visible = false
	bad_food.visible = false

	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", success)

func _on_timer_timeout():
	end_game(false, "¡Tiempo agotado!")
