extends Control

# Variables del juego
var posicion_gato_inicial: int  # 1=izq, 2=centro, 3=der
var posicion_gato_final: int
var fase_actual: String = "mostrar_gato"

# Nodos
@onready var cajas = {
	1: $Caja1,  
	2: $Caja2,
	3: $Caja3   
}
@onready var gato = $Gato
@onready var mensaje = $Mensaje
@onready var numero1 = $Numero1  # Sprite con número 1
@onready var numero2 = $Numero2  # Sprite con número 2
@onready var numero3 = $Numero3  # Sprite con número 3
@onready var fondo_mensaje = $FondoMensaje  # ColorRect para el fondo

# Posiciones fijas
var posiciones_fijas = {
	1: Vector2(350, 630),
	2: Vector2(700, 630),
	3: Vector2(1050, 630)
}

func _ready():
	# Ocultar números inicialmente
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
	
	# Configurar mensaje con fondo
	mensaje.text = "¡MEMORIZA!"
	fondo_mensaje.visible = true
	fondo_mensaje.color = Color(0, 0, 0, 0.7)  # Fondo semitransparente
	
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
		var caja = cajas[i+1]
		var nueva_pos = posiciones_fijas[posiciones_mezcladas[i]]
		tween.tween_property(caja, "position", nueva_pos, 1.5)
		tween.tween_property(caja, "rotation", deg_to_rad(360), 1.5)
	
	posicion_gato_final = posiciones_mezcladas[posicion_gato_inicial - 1]
	
	await tween.finished
	fase_actual = "adivinar"
	
	# Mostrar números sobre las cajas
	numero1.position = posiciones_fijas[1] + Vector2(0, -100)  # Arriba de caja izquierda
	numero2.position = posiciones_fijas[2] + Vector2(0, -100)  # Arriba de caja centro
	numero3.position = posiciones_fijas[3] + Vector2(0, -100)  # Arriba de caja derecha
	numero1.visible = true
	numero2.visible = true
	numero3.visible = true
	
	mensaje.text = "SELECCIONA"
	fondo_mensaje.color = Color(0, 0.5, 0, 0.7)  # Fondo verde oscuro

func _input(event):
	if fase_actual != "adivinar": return
	
	if event.is_action_pressed("tecla_1"):
		verificar_respuesta(1)
	elif event.is_action_pressed("tecla_2"):
		verificar_respuesta(2)
	elif event.is_action_pressed("tecla_3"):
		verificar_respuesta(3)

func verificar_respuesta(numero: int):
	# Ocultar números al verificar
	numero1.visible = false
	numero2.visible = false
	numero3.visible = false
	
	gato.position = posiciones_fijas[posicion_gato_final]
	gato.visible = true
	
	if numero == posicion_gato_final:
		mensaje.text = "¡CORRECTO!" 
		fondo_mensaje.color = Color(0, 0.5, 0, 0.7)  # Verde
	else:
		mensaje.text = "¡FALLASTE!" 
		fondo_mensaje.color = Color(0.5, 0, 0, 0.7)  # Rojo
	
	await get_tree().create_timer(3.0).timeout
	reiniciar_juego()

func reiniciar_juego():
	for i in range(3):
		cajas[i+1].position = posiciones_fijas[i+1]
		cajas[i+1].rotation = 0
	gato.visible = false
	fondo_mensaje.visible = false
	iniciar_juego()
