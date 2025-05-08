extends Control

var clicks_necesarios = 20
var clicks_actuales = 0

@onready var timer = $Timer
@onready var texto = $TextoInstruccion
@onready var gato = $Gato
@onready var lata = $Lata

func _ready():
	set_process_input(true)
	texto.text = "¡Presiona A rápido!"
	# Cambia estas rutas si tus imágenes están en otra carpeta
	gato.texture = preload("res://sprites/gatobocacerrada.png")
	lata.texture = preload("res://sprites/fish-can-pixel-art-food-260nw-2302674731.webp")

func _input(event):
	if event.is_action_pressed("ui_accept"):  # tecla Enter o botón A
		clicks_actuales += 1
		if clicks_actuales >= clicks_necesarios:
			victoria()

func _on_Timer_timeout():
	print("¡Se acabó el tiempo!")
	if clicks_actuales < clicks_necesarios:
		derrota()


func victoria():
	texto.text = "¡Lo lograste!"
	gato.texture = preload("res://sprites/gatofelix.png")
	lata.texture = preload("res://sprites/fish-can-pixel-art-food-260nw-2302674731.webp")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://escenas/fin_victoria.tscn")

func derrota():
	texto.text = "¡Muy lento!"
	gato.texture = preload("res://sprites/gatotriste.png")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://escenas/fin_derrota.tscn")
