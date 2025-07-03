extends Node2D
signal finished(success)

enum GatoEstado { BASE, IZQUIERDA, DERECHA }

var estado_objetivo: GatoEstado
var estado_actual: GatoEstado = GatoEstado.BASE

@onready var gato_base = $GatoBase
@onready var gato_foto = $GatoFoto
@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles
@onready var barra = $BarraTiempo
@onready var timer_barra = $TimerBarra
@onready var timer_cambio_foto = $TimerCambioFoto

# Texturas del jugador (GatoBase)
var texturas_base := {
	GatoEstado.BASE: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/Pure.png"),
	GatoEstado.IZQUIERDA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureIzquierda.png"),
	GatoEstado.DERECHA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureDerecha.png")
}

# Texturas de la foto (GatoFoto)
var texturas_foto := {
	GatoEstado.BASE: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFoto.png"),
	GatoEstado.IZQUIERDA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFotoIzquierda.png"),
	GatoEstado.DERECHA: preload("res://Microjuegos/Branco/7_Recrear foto/Sprite/PureFotoDerecha.png")
}

func _ready():
	texto.text = "¡Haz match con la foto!"
	texto.visible = true
	controles.text = "Usá ← / → / ↑ para moverte"
	controles.visible = true

	barra.max_value = 5.0
	barra.value = 5.0
	barra.visible = true

	randomize()
	estado_objetivo = GatoEstado.values().pick_random()
	actualizar_foto()
	actualizar_gato()

	timer_barra.start()
	timer_cambio_foto.start()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				estado_actual = GatoEstado.IZQUIERDA
			KEY_RIGHT:
				estado_actual = GatoEstado.DERECHA
			KEY_UP:
				estado_actual = GatoEstado.BASE
		actualizar_gato()

func actualizar_foto():
	gato_foto.texture = texturas_foto[estado_objetivo]

func actualizar_gato():
	gato_base.texture = texturas_base[estado_actual]

func _on_TimerCambioFoto_timeout():
	estado_objetivo = GatoEstado.values().pick_random()
	actualizar_foto()

func _on_TimerBarra_timeout():
	timer_cambio_foto.stop()
	barra.visible = false
	texto.visible = false
	controles.visible = false

	if estado_actual == estado_objetivo:
		texto.text = "¡Correcto!"
		emit_signal("finished", true)
	else:
		texto.text = "¡Fallaste!"
		emit_signal("finished", false)

	texto.visible = true

func _process(delta):
	if timer_barra.time_left > 0:
		barra.value = timer_barra.time_left
