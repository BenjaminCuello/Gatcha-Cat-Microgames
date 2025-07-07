extends Node2D
signal finished(success)

var flechas = [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
var flechas_texto = {"↑": KEY_UP, "↓": KEY_DOWN, "←": KEY_LEFT, "→": KEY_RIGHT}
var flechas_mostradas = []
var index_actual := 0
var esperando_input := false


@onready var texto = $TextoInstruccion
@onready var controles = $TextoControles
@onready var gato = $GatoSurfeando
@onready var olas = $Olas
@onready var timer_olas = $TimerOlas

var textura_ola1 : Texture2D
var textura_ola2 : Texture2D
var usando_ola1 := true

func _ready():
	gato.visible = true
	texto.text = "¡Prepárate!"
	texto.visible = true
	controles.visible = false

# Carga las texturas
	textura_ola1 = load("res://Microjuegos/Branco/8_Surfeando/Sprites/ola1.png")
	textura_ola2 = load("res://Microjuegos/Branco/8_Surfeando/Sprites/ola2.png")

	# Establece la textura inicial
	olas.texture = textura_ola1

	# Conecta el timer si no lo hiciste desde el editor
	timer_olas.timeout.connect(_on_TimerOlas_timeout)
	
	$BarraTiempo.max_value = 6.0
	$BarraTiempo.value = 6.0
	$BarraTiempo.visible = true
	$TimerBarra.start()

	await get_tree().create_timer(1.0).timeout
	texto.visible = false
	$TimerApertura.start()

	for i in range(6):
		flechas_mostradas.append(flechas[randi() % flechas.size()])

func _on_TimerApertura_timeout():
	mostrar_flecha()

func mostrar_flecha():
	if index_actual >= flechas_mostradas.size():
		victoria()
		return

	esperando_input = true
	var keycode = flechas_mostradas[index_actual]

	var simbolo = ""
	for s in flechas_texto.keys():
		if flechas_texto[s] == keycode:
			simbolo = s
			break

	controles.text = "Presiona:\n" + simbolo
	controles.visible = true

	var tiempos = [0.8, 1.0, 1.2]
	$TimerRespuesta.start(tiempos.pick_random())


func _input(event):
	if not esperando_input:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return

		var keycode_presionado = event.keycode
		var esperado = flechas_mostradas[index_actual]

		if keycode_presionado == esperado:
			acierto()
		else:
			derrota()

func acierto():
	esperando_input = false
	$TimerRespuesta.stop()
	controles.visible = false

	index_actual += 1
	mostrar_flecha()

func derrota():
	if esperando_input:
		esperando_input = false
		$TimerRespuesta.stop()
		$TimerBarra.stop()

		texto.text = "¡Fallaste!"
		texto.visible = true
		controles.visible = false

		await get_tree().create_timer(1.0).timeout
		emit_signal("finished", false)

func victoria():
	$TimerBarra.stop()
	texto.text = "¡Genial!"
	texto.visible = true
	await get_tree().create_timer(1.2).timeout
	emit_signal("finished", true)

func _on_TimerRespuesta_timeout():
	derrota()

func _on_TimerBarra_timeout():
	derrota()
	
func _on_TimerOlas_timeout():
	if usando_ola1:
		olas.texture = textura_ola2
	else:
		olas.texture = textura_ola1
	usando_ola1 = !usando_ola1

func _process(delta):
	if $TimerBarra.time_left > 0:
		$BarraTiempo.value = $TimerBarra.time_left
