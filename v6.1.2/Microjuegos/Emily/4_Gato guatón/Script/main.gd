extends Node2D

@onready var player = $Player
@onready var good_food = $GoodFood
@onready var bad_food = $BadFood
@onready var label = $Label

var screen_size
var fall_speed = 500
var food_limit_y = 1000
var game_over = false
var fall_count = 0
var max_falls = 2
var waiting_next_fall = false

func _ready():
	randomize()
	screen_size = get_viewport_rect().size
	label.text = "¡Come bien!"
	launch_food()

	good_food.connect("body_entered", Callable(self, "_on_good_food_body_entered"))
	bad_food.connect("body_entered", Callable(self, "_on_bad_food_body_entered"))

func _process(delta):
	if game_over:
		return

	handle_player_input(delta)
	move_foods(delta)

func handle_player_input(delta):
	var dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	player.position.x += dir * 800 * delta
	player.position.x = clamp(player.position.x, 0, screen_size.x)

func move_foods(delta):
	if !good_food.visible:
		return

	# Mover comida
	good_food.position.y += fall_speed * delta
	bad_food.position.y += fall_speed * delta

	# Si la buena cae sin atraparse = derrota
	if good_food.position.y > food_limit_y:
		end_game("¡Derrota!")

	# Si la basura cae sola, simplemente desaparece
	if bad_food.position.y > food_limit_y:
		bad_food.visible = false

func launch_food():
	if fall_count >= max_falls:
		end_game("¡Victoria!")
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
	if body == player and not game_over:
		good_food.visible = false
		bad_food.visible = false
		await get_tree().create_timer(0.5).timeout
		launch_food()

func _on_bad_food_body_entered(body):
	if body == player and not game_over:
		end_game("¡Derrota! Comiste basura.")

func end_game(message):
	game_over = true
	label.text = message
	good_food.visible = false
	bad_food.visible = false
