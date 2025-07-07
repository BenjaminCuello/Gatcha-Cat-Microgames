extends Node2D

@onready var crosshair = $Crosshair
@onready var target = $Target
@onready var timer = $GameTimer
@onready var label = $Label
@onready var time_bar = $TimeBar

var crosshair_speed = 1000
var target_speed = 500
var screen_size
var direction = Vector2(1, 0)
var game_over = false

func _ready():
	screen_size = get_viewport_rect().size
	reset_crosshair()
	reset_target()

	# Configurar el temporizador
	timer.wait_time = 9  # segundos
	timer.one_shot = true
	timer.start()

	# Configurar barra de tiempo
	time_bar.max_value = timer.wait_time
	time_bar.value = timer.wait_time

	# Señales
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	label.text = "APUNTA Y DISPARA"

func _process(delta):
	if game_over:
		return

	move_crosshair(delta)
	move_target(delta)

	# Actualizar barra de tiempo
	time_bar.value = timer.time_left

	# Disparo
	if Input.is_action_just_pressed("ui_accept"):
		check_hit()

func move_crosshair(delta):
	var dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	crosshair.position += dir.normalized() * crosshair_speed * delta
	crosshair.position.x = clamp(crosshair.position.x, 0, screen_size.x)
	crosshair.position.y = clamp(crosshair.position.y, 0, screen_size.y)

func move_target(delta):
	target.position += direction * target_speed * delta
	if target.position.x < 0 or target.position.x > screen_size.x:
		direction.x *= -1

func check_hit():
	if game_over:
		return
	var distance = crosshair.position.distance_to(target.position)
	if distance < 190:
		end_game("🎯 ¡Victoria! Le diste al blanco")
	else:
		end_game("❌ ¡Fallaste el disparo!")

func _on_timer_timeout():
	end_game("⏰ ¡Tiempo agotado! Perdiste")

func reset_crosshair():
	crosshair.position = screen_size / 2

func reset_target():
	target.position = Vector2(0, 200)

func end_game(message):
	if game_over:
		return
	game_over = true
	label.text = message
	target.visible = false
	timer.stop()
