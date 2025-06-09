extends Node2D
signal finished(success) # señal que se emite al terminar el microjuego (true si gana, false si pierde)

# referencias a nodos
@onready var texto = $TextoInstruccion # label que muestra la instruccion inicial
@onready var controles = $TextoControles # label que muestra las teclas u opciones
@onready var barra_tiempo = $BarraTiempo # barra que muestra el tiempo restante
@onready var timer_apertura = $TimerApertura # espera antes de comenzar el juego real
@onready var timer_barra = $TimerBarra # controla la duracion total del microjuego
@onready var timer_respuesta = $TimerRespuesta # tiempo limite para que el jugador reaccione

var juego_activo := true # controla si el juego esta en curso o ya termino
var duracion_juego := 5.0 # segundos que dura el microjuego

func _ready():
	# mostrar instruccion inicial
	texto.text = "¡Haz esto!"
	texto.visible = true
	controles.visible = false

	# configurar barra de tiempo
	barra_tiempo.max_value = duracion_juego
	barra_tiempo.value = duracion_juego
	barra_tiempo.visible = true

	# comenzar cuenta regresiva del microjuego
	timer_barra.start(duracion_juego)

	# esperar 1 segundo para mostrar la instruccion
	await get_tree().create_timer(1.0).timeout
	texto.visible = false
	timer_apertura.start() # cuando termina, se activa el juego real
#RECORDAR QUE LOS TIMER SE DEBEN CONECTAR CON LOS NODOS PARA QUE FUNCIONEN CORRECTAMENTE
func _on_TimerApertura_timeout():
	# empieza el microjuego real
	controles.text = "Presiona [A]"
	controles.visible = true
	timer_respuesta.start(2.0) # tiempo limite para presionar la tecla

func _on_TimerRespuesta_timeout():
	# si el jugador no respondio a tiempo, pierde
	derrota()

func _on_TimerBarra_timeout():
	# si se acabo el tiempo total del microjuego, pierde
	derrota()

func _process(delta):
	# actualizar la barra de tiempo visual
	if timer_barra.time_left > 0:
		barra_tiempo.value = timer_barra.time_left

func _input(event):
	if not juego_activo:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			return # ESC se usa para abrir el menu de pausa

		if event.keycode == KEY_A:
			victoria() # si presiona A, gana

func victoria():
	juego_activo = false
	timer_respuesta.stop()
	timer_barra.stop()
	emit_signal("finished", true) # avisar que gano

func derrota():
	if juego_activo:
		juego_activo = false
		timer_respuesta.stop()
		timer_barra.stop()
		emit_signal("finished", false) # avisar que perdio
