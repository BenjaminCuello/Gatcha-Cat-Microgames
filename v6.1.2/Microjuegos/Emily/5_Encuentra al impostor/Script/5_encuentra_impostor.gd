extends Node2D
signal finished(success)

@onready var animales = [$Gato, $Mapache, $Zarigueya]
@onready var flecha = $Flecha
@onready var texto_instruccion = $TextoInstruccion
@onready var texto_controles = $TextoControles
@onready var timer_barra = $TimerBarra
@onready var barra_tiempo = $BarraTiempo

var ancho_pantalla = ProjectSettings.get_setting("display/window/size/viewport_width")
var y_base = 700
var espacio = 500

var posiciones = [
	Vector2(ancho_pantalla / 2 - espacio, y_base),
	Vector2(ancho_pantalla / 2, y_base - 100),  # El del medio más arriba
	Vector2(ancho_pantalla / 2 + espacio, y_base)
]

var orden_animales = []
var indice_correcto: int = 0
var indice_flecha: int = 0
var terminado = false

func _ready():
	terminado = false
	randomize()
	iniciar_juego()

func iniciar_juego():
	texto_instruccion.text = "Encuentra al gato"
	texto_controles.text = "Usa ← → para mover. 
	Espacio para elegir."
	texto_instruccion.visible = true
	texto_controles.visible = true

	# Mezclar los animales
	orden_animales = animales.duplicate()
	orden_animales.shuffle()

	for i in range(orden_animales.size()):
		orden_animales[i].global_position = posiciones[i]
		orden_animales[i].visible = true
		if orden_animales[i].name == "Gato":
			indice_correcto = i

	# Posicionar flecha
	indice_flecha = 0
	_update_flecha_pos()

	# Barra de tiempo simple
	barra_tiempo.max_value = 6.0
	barra_tiempo.value = barra_tiempo.max_value
	barra_tiempo.visible = true

	timer_barra.start()

func _input(event):
	if terminado:
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_LEFT:
				indice_flecha = (indice_flecha - 1 + 3) % 3
				_update_flecha_pos()
			KEY_RIGHT:
				indice_flecha = (indice_flecha + 1) % 3
				_update_flecha_pos()
			KEY_SPACE:
				verificar_respuesta()

func _update_flecha_pos():
	var offset_y = -200
	var offset_x = -20
	if indice_flecha == 1:  # El del medio más arribaS
		offset_y = -200
	flecha.global_position = posiciones[indice_flecha] + Vector2(offset_x, offset_y)

func verificar_respuesta():
	terminado = true
	timer_barra.stop()
	barra_tiempo.visible = false
	texto_controles.visible = false

	if indice_flecha == indice_correcto:
		texto_instruccion.text = "¡Correcto! Era el gato."
		emit_signal("finished", true)
	else:
		texto_instruccion.text = "¡Fallaste! Eso no era un gato."
		emit_signal("finished", false)

	await get_tree().create_timer(1.0).timeout

func _on_TimerBarra_timeout():
	if terminado:
		return
	terminado = true
	texto_instruccion.text = "¡Se acabó el tiempo!"
	texto_controles.visible = false
	barra_tiempo.visible = false
	emit_signal("finished", false)

func _process(delta):
	if not terminado and not timer_barra.is_stopped():
		barra_tiempo.value = timer_barra.time_left
