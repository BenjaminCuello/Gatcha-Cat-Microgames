extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado

var posicion_gato_inicial: int
var indice_caja_con_gato: int = 0
var fase_actual: String = "mostrar_gato"
var terminado := false

# Variables de dificultad
var nivel_dificultad = 1
var tiempo_total = 6.0
var tiempo_memorizacion = 2.0
var tiempo_mezcla = 1.5
var cantidad_cajas = 3

@onready var cajas = {
    1: $Caja1,
    2: $Caja2,
    3: $Caja3
}
@onready var gato = $Gato
@onready var numero1 = $Numero1
@onready var numero2 = $Numero2
@onready var numero3 = $Numero3
@onready var fondo_mensaje = $FondoMensaje

# Sistema Gatcha
@onready var texto_instruccion = $TextoInstruccion
@onready var texto_controles = $TextoControles
@onready var barra_tiempo = $BarraTiempo
@onready var timer_apertura = $TimerApertura
@onready var timer_barra = $TimerBarra

# Posiciones fijas para cajas y números
var posiciones_fijas = {
    1: Vector2(500, 700),
    2: Vector2(1000, 700),
    3: Vector2(1500, 700)
}
var posiciones_numeros_fijas = {
    1: Vector2(500, 600),
    2: Vector2(1000, 600),
    3: Vector2(1500, 600)
}
var orden_cajas := {}

func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:
			tiempo_total = 6.0
			tiempo_memorizacion = 2.0
			tiempo_mezcla = 1.5
			cantidad_cajas = 3
		2:
			tiempo_total = 5.5
			tiempo_memorizacion = 1.8
			tiempo_mezcla = 1.3
			cantidad_cajas = 3
		3:
			tiempo_total = 5.0
			tiempo_memorizacion = 1.5
			tiempo_mezcla = 1.0
			cantidad_cajas = 3
		4:
			tiempo_total = 4.5
			tiempo_memorizacion = 1.3
			tiempo_mezcla = 0.8
			cantidad_cajas = 3
		5:
			tiempo_total = 4.0
			tiempo_memorizacion = 1.0
			tiempo_mezcla = 0.6
			cantidad_cajas = 3
		6:
			tiempo_total = 3.5
			tiempo_memorizacion = 0.8
			tiempo_mezcla = 0.5
			cantidad_cajas = 3
		7:
			tiempo_total = 3.0
			tiempo_memorizacion = 0.6
			tiempo_mezcla = 0.4
			cantidad_cajas = 3
		8:
			tiempo_total = 2.5
			tiempo_memorizacion = 0.4
			tiempo_mezcla = 0.3
			cantidad_cajas = 3

	print("Nivel configurado:", nivel_dificultad)
	print("Tiempo total:", tiempo_total)
	print("Tiempo memorización:", tiempo_memorizacion)
	print("Tiempo mezcla:", tiempo_mezcla)
	print("Cantidad cajas:", cantidad_cajas)

func _ready():
    terminado = false
    randomize()
    texto_instruccion.text = "¡Memoriza la caja!"
    texto_instruccion.visible = true
    texto_controles.visible = false
    fondo_mensaje.visible = false
    numero1.visible = false
    numero2.visible = false
    numero3.visible = false

	# Configurar barra de tiempo según dificultad
	barra_tiempo.max_value = tiempo_total
	barra_tiempo.value = tiempo_total
	barra_tiempo.visible = true
	
	# Configurar timer según dificultad
	timer_barra.wait_time = tiempo_total
	timer_barra.start()
	timer_apertura.start(1.0)

func _on_TimerApertura_timeout():
    texto_instruccion.visible = false
    texto_controles.text = "Presiona 1, 2 o 3"
    texto_controles.visible = true
    iniciar_juego()

func iniciar_juego():
	fase_actual = "mostrar_gato"
	posicion_gato_inicial = randi() % cantidad_cajas + 1

    for i in cajas.keys():
        cajas[i].position = posiciones_fijas[i]

    var caja_inicial = cajas[posicion_gato_inicial]
    var pos = caja_inicial.global_position
    if gato.get_parent(): gato.get_parent().remove_child(gato)
    add_child(gato)
    gato.global_position = pos
    gato.visible = true

	# Tiempo de memorización según dificultad
	await get_tree().create_timer(tiempo_memorizacion).timeout

    gato.visible = false
    fase_actual = "mezclar"
    await mezclar_cajas()
    mostrar_opciones()

func mezclar_cajas():
    var posiciones_mezcladas = [1, 2, 3]
    posiciones_mezcladas.shuffle()

    var tween = create_tween()
    tween.set_parallel(true)

	for i in range(cantidad_cajas):
		var visible = i + 1
		var caja_index = posiciones_mezcladas[i]
		var caja = cajas[caja_index]
		var nueva_pos = posiciones_fijas[visible]

		orden_cajas[visible] = caja_index
		# Tiempo de mezcla según dificultad
		tween.tween_property(caja, "position", nueva_pos, tiempo_mezcla)
		tween.tween_property(caja, "rotation", deg_to_rad(360), tiempo_mezcla)

        if caja_index == posicion_gato_inicial:
            indice_caja_con_gato = visible

    await tween.finished
    fase_actual = "adivinar"

func mostrar_opciones():
    numero1.position = posiciones_numeros_fijas[1]
    numero2.position = posiciones_numeros_fijas[2]
    numero3.position = posiciones_numeros_fijas[3]

    numero1.visible = true
    numero2.visible = true
    numero3.visible = true

func _input(event):
    if terminado or fase_actual != "adivinar":
        return

    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_1: verificar_respuesta(1)
            KEY_2: verificar_respuesta(2)
            KEY_3: verificar_respuesta(3)

func verificar_respuesta(numero: int):
	if terminado:
		return
	terminado = true
	timer_barra.stop()
	barra_tiempo.visible = false
	texto_controles.visible = false
	texto_instruccion.visible = true

    numero1.visible = false
    numero2.visible = false
    numero3.visible = false

    var caja_correcta = cajas[orden_cajas[indice_caja_con_gato]]
    if gato.get_parent(): gato.get_parent().remove_child(gato)
    caja_correcta.add_child(gato)
    gato.position = Vector2.ZERO
    gato.visible = true

    if numero == indice_caja_con_gato:
        texto_instruccion.text = "¡Correcto!"
        await get_tree().create_timer(1.0).timeout
        emit_signal("finished", true)
        emit_signal("microjuego_superado")

    else:
        texto_instruccion.text = "¡Fallaste!"
        await get_tree().create_timer(1.0).timeout
        emit_signal("finished", false)
        emit_signal("microjuego_fallado")


func _on_TimerBarra_timeout():
	if terminado:
		return
	terminado = true
	barra_tiempo.visible = false
	texto_instruccion.text = "¡Se acabó el tiempo!"
	texto_instruccion.visible = true
	texto_controles.visible = false
	await get_tree().create_timer(1.0).timeout
	emit_signal("finished", false)

func _process(delta):
    if not terminado and timer_barra.is_stopped() == false:
        barra_tiempo.value = timer_barra.time_left
