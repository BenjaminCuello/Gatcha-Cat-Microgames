extends Control
signal finished(success)

var clicks_necesarios = 15
var clicks_actuales = 0
var terminado := false

@onready var timer = $Timer
@onready var texto = $TextoInstruccion
@onready var gato = $Gato
@onready var lata = $Lata

func _ready():
	set_process_input(true)
	clicks_actuales = 0
	texto.text = "¡Presiona A rápido!"

	# Cambia las rutas si usas otras imágenes
	gato.texture = preload("res://sprites/micro 1/gatobocacerrada.png")
	lata.texture = preload("res://sprites/micro 3/lata.webp")

	timer.start(3.0)  # Duración del microjuego (en segundos)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_A:
		clicks_actuales += 1
		if clicks_actuales >= clicks_necesarios:
			victoria()

func _on_Timer_timeout():
	if clicks_actuales < clicks_necesarios:
		derrota()
	else:
		victoria()  # (por si justo llega al límite)

func victoria():
	if terminado: return
	terminado = true

	texto.text = "¡Lo lograste!"
	gato.texture = preload("res://sprites/micro 1/gatofelix.png")
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", true)

func derrota():
	if terminado: return
	terminado = true

	texto.text = "¡Muy lento!"
	gato.texture = preload("res://sprites/micro 1/gatotriste.png")
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)
