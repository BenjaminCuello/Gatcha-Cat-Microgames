extends Control
signal finished(success)

var clicks_necesarios = 0
var clicks_actuales = 0
var terminado := false

@onready var timer = $Timer
@onready var texto = $TextoInstruccion
@onready var gato = $Gato
@onready var lata = $Lata

func _ready():
	set_process_input(true)
	terminado = false
	clicks_actuales = 0

	# Elegir clicks aleatoriamente entre 15, 16 o 17
	var opciones = [15, 16, 17]
	clicks_necesarios = opciones.pick_random()

	texto.text = "¡Presiona A rápido!"
	texto.visible = true

	# Cargar imágenes
	gato.texture = preload("res://sprites/micro 16/gatobocacerrada.png")
	lata.texture = preload("res://sprites/micro 21/lata.png")

	timer.start(3.0)

	# Ocultar el texto después de 0.5 s
	await get_tree().create_timer(0.5).timeout
	texto.visible = false

func _input(event):
	if terminado:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			return

		if event.keycode == KEY_A:
			clicks_actuales += 1

			# Animación de shake de la lata
			var original_pos = lata.position
			var tween = create_tween()
			tween.tween_property(lata, "position", original_pos + Vector2(6, -4), 0.05)
			tween.tween_property(lata, "position", original_pos + Vector2(-5, 3), 0.05)
			tween.tween_property(lata, "position", original_pos + Vector2(4, -2), 0.05)
			tween.tween_property(lata, "position", original_pos, 0.05)

			if clicks_actuales >= clicks_necesarios:
				victoria()

func _on_Timer_timeout():
	if terminado:
		return

	if clicks_actuales < clicks_necesarios:
		derrota()
	else:
		victoria()

func victoria():
	if terminado: return
	terminado = true

	texto.text = "¡Lo lograste!"
	texto.visible = true
	gato.texture = preload("res://sprites/micro 16/gatofelix.png")
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", true)

func derrota():
	if terminado: return
	terminado = true

	texto.text = "¡Muy lento!"
	texto.visible = true
	gato.texture = preload("res://sprites/micro 16/gatotriste.png")
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)
