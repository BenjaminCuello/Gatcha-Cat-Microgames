extends Node2D
signal finished(success)

var posicion_gato_inicial: int
var indice_caja_con_gato: int = 0  # Guarda el número visible donde terminó el gato
var fase_actual: String = "mostrar_gato"
var terminado := false

@onready var cajas = {
	1: $Caja1,
	2: $Caja2,
	3: $Caja3
}
@onready var gato = $Gato
@onready var mensaje = $Mensaje
@onready var numero1 = $Numero1
@onready var numero2 = $Numero2
@onready var numero3 = $Numero3
@onready var fondo_mensaje = $FondoMensaje

# Posiciones fijas para cada caja (donde estarán las cajas)
var posiciones_fijas = {
	1: Vector2(500, 700),
	2: Vector2(1000, 700),
	3: Vector2(1500, 700)
}

# Posiciones fijas para cada número visible (estos son estáticos)
var posiciones_numeros_fijas = {
	1: Vector2(500, 600),
	2: Vector2(1000, 600),
	3: Vector2(1500, 600)
}

var orden_cajas := {}  # número visible -> índice de caja

func _ready():
	terminado = false
	numero1.visible = false
	numero2.visible = false
	numero3.visible = false
	fondo_mensaje.visible = false
	randomize()
	iniciar_juego()

func iniciar_juego():
	fase_actual = "mostrar_gato"
	posicion_gato_inicial = randi() % 3 + 1

	# Coloca las cajas en posición inicial
	for i in cajas.keys():
		cajas[i].position = posiciones_fijas[i]

	# Coloca el gato en la caja original
	var caja_inicial = cajas[posicion_gato_inicial]
	var posicion_destino = caja_inicial.global_position

	if gato.get_parent():
		gato.get_parent().remove_child(gato)
	add_child(gato)
	gato.global_position = posicion_destino
	gato.visible = true

	mensaje.text = "¡MEMORIZA!"
	fondo_mensaje.visible = true
	fondo_mensaje.color = Color(0, 0, 0, 0.7)

	await get_tree().create_timer(2.0).timeout

	gato.visible = false
	fase_actual = "mezclar"
	mensaje.text = "¡MEZCLANDO CAJAS!"
	await mezclar_cajas()
	mostrar_opciones()

func mezclar_cajas() -> void:
	var posiciones_mezcladas = [1, 2, 3]
	posiciones_mezcladas.shuffle()

	var tween = create_tween()
	tween.set_parallel(true)

	for i in range(3):
		var numero_visible = i + 1
		var caja_index = posiciones_mezcladas[i]
		var caja = cajas[caja_index]
		var nueva_pos = posiciones_fijas[numero_visible]

		orden_cajas[numero_visible] = caja_index

		tween.tween_property(caja, "position", nueva_pos, 1.5)
		tween.tween_property(caja, "rotation", deg_to_rad(360), 1.5)

		# Guardamos el número visible donde terminó el gato
		if caja_index == posicion_gato_inicial:
			indice_caja_con_gato = numero_visible

	await tween.finished
	fase_actual = "adivinar"

func mostrar_opciones():
	# Aquí asignamos posiciones fijas a los números para que no se muevan con las cajas
	numero1.position = posiciones_numeros_fijas[1]
	numero2.position = posiciones_numeros_fijas[2]
	numero3.position = posiciones_numeros_fijas[3]

	numero1.visible = true
	numero2.visible = true
	numero3.visible = true

	mensaje.text = "SELECCIONA"
	fondo_mensaje.color = Color(0, 0.5, 0, 0.7)

func _input(event):
	if terminado or fase_actual != "adivinar":
		return

	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: verificar_respuesta(1)
			KEY_2: verificar_respuesta(2)
			KEY_3: verificar_respuesta(3)

func verificar_respuesta(numero: int):
	numero1.visible = false
	numero2.visible = false
	numero3.visible = false

	# Mostrar gato en la caja correcta (según dónde terminó el gato)
	var caja_correcta = cajas[orden_cajas[indice_caja_con_gato]]
	if gato.get_parent():
		gato.get_parent().remove_child(gato)
	caja_correcta.add_child(gato)
	gato.position = Vector2.ZERO
	gato.visible = true

	if numero == indice_caja_con_gato:
		mensaje.text = "¡CORRECTO!"
		fondo_mensaje.color = Color(0, 0.5, 0, 0.7)
		await get_tree().create_timer(1.2).timeout
		emit_signal("finished", true)
	else:
		mensaje.text = "¡FALLASTE!"
		fondo_mensaje.color = Color(0.5, 0, 0, 0.7)
		await get_tree().create_timer(1.2).timeout
		emit_signal("finished", false)

	terminado = true
