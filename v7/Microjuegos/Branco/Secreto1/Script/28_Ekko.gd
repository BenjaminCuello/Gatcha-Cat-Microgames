extends CharacterBody2D

@export var velocidad := 350.0
@export var radio_cavar := 250.0

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	velocity = input_vector * velocidad
	move_and_slide()

	# Limitar dentro del viewport
	var size = get_viewport_rect().size
	global_position.x = clamp(global_position.x, 0, size.x)
	global_position.y = clamp(global_position.y, 0, size.y)


func esta_cerca_de(objetivo: Node2D) -> bool:
	return global_position.distance_to(objetivo.global_position) <= radio_cavar
