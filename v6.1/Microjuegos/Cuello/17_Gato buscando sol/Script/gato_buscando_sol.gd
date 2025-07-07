extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

var velocidad := 900.0
var toques_realizados := 0
var toques_necesarios := 3
var anim_timer := 0.0
var anim_interval := 0.1
var mostrando_quieto := true
var sol_tocado := false
var tiempo_total := 7.0
var tiempo_restante := 7.0
var estado_sol := "quieto" # puede ser "quieto" o "moviendo"

@onready var gato = $Gato
@onready var sprite_quieto = $Gato/SpriteGatoQuieto
@onready var sprite_caminando = $Gato/SpriteGatoCaminando
@onready var rayo_sol = $RayoSol
@onready var sprite_sol = $RayoSol/SpriteSol
@onready var col_sol = $RayoSol/CollisionShape2D
@onready var barra = $BarraTiempo
@onready var texto = $TextoInstruccion
@onready var timer_apertura = $TimerApertura
@onready var timer_mov_sol = $RayoSol/TimerMovimientoSol
@onready var label_contador = $ContadorToques

func _ready():
	randomize()
	rayo_sol.visible = true
	sprite_sol.visible = true
	texto.text = "¡Encuentra el sol!"
	texto.visible = true
	barra.visible = false
	label_contador.visible = false
	sprite_quieto.visible = true
	sprite_caminando.visible = false
	timer_apertura.start(1.0)

func _on_TimerApertura_timeout():
	texto.visible = false
	barra.visible = true
	barra.min_value = 0.0
	barra.max_value = tiempo_total
	label_contador.visible = true
	label_contador.text = "Toques: 0 / 3"
	_mover_sol()


func _process(delta):
	if toques_realizados >= toques_necesarios:
		return

	# Movimiento del gato
	var dir := Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if dir != Vector2.ZERO:
		gato.position += dir.normalized() * velocidad * delta
		anim_timer += delta
		if anim_timer >= anim_interval:
			anim_timer = 0.0
			mostrando_quieto = !mostrando_quieto
			sprite_quieto.visible = mostrando_quieto
			sprite_caminando.visible = not mostrando_quieto
	else:
		sprite_quieto.visible = true
		sprite_caminando.visible = false
		anim_timer = 0.0

	# Actualizar tiempo restante
	tiempo_restante -= delta
	barra.value = tiempo_restante

	if tiempo_restante <= 0.0:
		_texto_perder()

func _on_TimerMovimientoSol_timeout():
	if estado_sol == "moviendo":
		_esperar_sol()
	else:
		_mover_sol()


func _on_RayoSol_body_entered(body):
	if body == gato and not sol_tocado:
		sol_tocado = true
		toques_realizados += 1
		label_contador.text = "Toques: %d / %d" % [toques_realizados, toques_necesarios]
		if toques_realizados >= toques_necesarios:
			_texto_ganar()

func _texto_ganar():
	texto.text = "¡Ganaste!"
	texto.visible = true
	set_process(false)
	emit_signal("microjuego_superado")
	await get_tree().create_timer(1.0).timeout
	
	emit_signal("finished", true)

func _texto_perder():
	texto.text = "¡Perdiste!"
	texto.visible = true
	set_process(false)
	emit_signal("microjuego_fallado")
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)
func _mover_sol():
	estado_sol = "moviendo"
	var margen := 100
	var area := get_viewport_rect().size
	var nueva_pos = Vector2(
		randf_range(margen, area.x - margen),
		randf_range(margen, area.y - margen)
	)
	rayo_sol.position = nueva_pos
	sol_tocado = false
	timer_mov_sol.start(2.0) # se queda quieto 2 segundos

func _esperar_sol():
	estado_sol = "quieto"
	timer_mov_sol.start(1.0) # después de 1s vuelve a moverse
