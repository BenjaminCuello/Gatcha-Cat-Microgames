extends Node2D
signal finished(success)

var posicion_gato_inicial: int
var posicion_gato_final: int
var fase_actual: String = "mostrar_gato"

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

var posiciones_fijas = {
	1: Vector2(248, 347),
	2: Vector2(561, 347),
	3: Vector2(862, 347)
}

var terminado := false

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
	gato.position = posiciones_fijas[posicion_gato_inicial]
	gato.visible = true

	mensaje.text = "¡MEMORIZA!"
	fondo_mensaje.visible = true
	fondo_mensaje.color = Color(0, 0, 0, 0.7)

	await get_tree().create_timer(2.0).timeout
	gato.visible = false
	fase_actual = "mezclar"
	mensaje.text = "¡MEZCLANDO CAJAS!"
	mezclar_cajas()

func mezclar_cajas():
	var posiciones_mezcladas = [1, 2, 3]
	posiciones_mezcladas.shuffle()

	var tween = create_tween()
	tween.set_parallel(true)

	for i in range(3):
		var caja = cajas[i + 1]
		var nueva_pos = posiciones_fijas[posiciones_mezcladas[i]]
		tween.tween_property(caja, "position", nueva_pos, 1.5)
		tween.tween_property(caja, "rotation", deg_to_rad(360), 1.5)

	posicion_gato_final = posiciones_mezcladas[posicion_gato_inicial - 1]

	await tween.finished
	fase_actual = "adivinar"

	numero1.position = posiciones_fijas[1] + Vector2(0, -100)
	numero2.position = posiciones_fijas[2] + Vector2(0, -100)
	numero3.position = posiciones_fijas[3] + Vector2(0, -100)
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
	gato.position = posiciones_fijas[posicion_gato_final]
	gato.visible = true

	if numero == posicion_gato_final:
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
