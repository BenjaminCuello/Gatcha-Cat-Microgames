class_name PataGato
extends CharacterBody2D

#velocidad de movimiento para gato
@export var vel_gato = 100

func _physics_process(delta):
	#separados para que se pueda ir orizontal y verticalmente
	
	if Input.is_key_pressed(KEY_A): #izquierda
		velocity.x = vel_gato * -1
	elif Input.is_key_pressed(KEY_D): #derecha
		velocity.x = vel_gato
	else: #ninguno
		velocity.x = 0
	
	if Input.is_key_pressed(KEY_W): #arriba
		velocity.y = vel_gato * -1
	elif Input.is_key_pressed(KEY_S): #abajo
		velocity.y = vel_gato
	else: #ninguno
		velocity.y = 0
	
	move_and_slide()

func pres_izquierda():
	velocity.x = vel_gato * -1
