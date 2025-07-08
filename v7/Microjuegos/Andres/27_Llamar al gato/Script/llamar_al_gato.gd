extends Node2D
signal finished(success)
signal microjuego_superado
signal microjuego_fallado


@onready var MostrarNomGat = $NombreGato
@onready var line_edit = $LineEdit
@onready var label = $EscribirNombre
@onready var Indstrucción = $Instruccion

@onready var gato = $Sprite2D
@onready var taza = $Taza

@onready var timer = $TiempoRestante

@export var TiempoJuego = 5

# Variables para la dificultad
var nivel_dificultad = 1

# Lista de nombres para escoger (se ajustará según dificultad)
var nombres = ["Leo", "Destructor", "Lucas", "Michi", "Diego", "Luna", "Pelusa", "Michifu","Pablonator"]

# Al iniciar el juego
var nombre = ""

# Función para configurar la dificultad (llamada desde el sistema principal)
func configurar_dificultad(nivel: int):
	nivel_dificultad = nivel
	ajustar_parametros_dificultad()

# Función para ajustar los parámetros según el nivel
func ajustar_parametros_dificultad():
	match nivel_dificultad:
		1:  # Nivel 1 - Fácil
			TiempoJuego = 6.0
			nombres = ["Leo", "Michi", "Luna", "Diego"]  # Nombres cortos y fáciles
		2:  # Nivel 2
			TiempoJuego = 5.0
			nombres = ["Leo", "Michi", "Luna", "Diego", "Lucas", "Pelusa"]
		3:  # Nivel 3
			TiempoJuego = 4.0
			nombres = ["Destructor", "Lucas", "Pelusa", "Michifu", "Leo", "Luna"]
		4:  # Nivel 4
			TiempoJuego = 3.0
			nombres = ["Destructor", "Pablonator", "Michifu", "Pelusa", "Lucas"]
		5:  # Nivel 5
			TiempoJuego = 2.5
			nombres = ["Destructor", "Pablonator", "Michifu", "SuperGato", "MegaMichi"]
		6:  # Nivel 6
			TiempoJuego = 2.0
			nombres = ["Pablonator", "Destructor", "SuperGato", "MegaMichi", "UltraFelino"]
		7:  # Nivel 7
			TiempoJuego = 1.8
			nombres = ["Pablonator", "Destructor", "SuperGato", "MegaMichi", "UltraFelino", "MaximusCatus"]
		8:  # Nivel 8 - Máximo
			TiempoJuego = 1.5
			nombres = ["Pablonator", "Destructor", "SuperGato", "MegaMichi", "UltraFelino", "MaximusCatus", "GigaGatitus"]

	print("=== DIFICULTAD CONFIGURADA ===")
	print("Nivel: ", nivel_dificultad)
	print("Tiempo: ", TiempoJuego, " segundos")
	print("Nombres disponibles: ", nombres.size())
	print("===============================")

func _ready():
	# Configurar dificultad por defecto (será sobrescrita por el sistema principal)
	ajustar_parametros_dificultad()
	
	# Elegir nombre DESPUÉS de configurar la dificultad
	nombre = nombres[randi() % nombres.size()].to_upper()
	
	gato.position = Vector2(931.0,499.0)
	taza.position = Vector2(472.0, 645.0)
	taza.rotation = 0
	line_edit.grab_focus()
	MostrarNomGat.text = nombre
	# Conectamos la señal "text_changed" del LineEdit al Label
	line_edit.connect("text_changed", Callable(self, "_on_text_changed"))
	await get_tree().create_timer(1.5).timeout
	Indstrucción.visible = false
	$TiempoRestante.start(TiempoJuego)
	$barraDeTiempo.max_value = TiempoJuego
	$barraDeTiempo.min_value = 0

var bien
func _on_text_changed(new_text):
	if not bien:
		label.text = new_text + "!!!"
	if new_text.to_upper() == nombre.to_upper():
		$TiempoRestante.stop()
		emit_signal("finished", true)
		emit_signal("microjuego_superado")

		Indstrucción.text = "Ganaste!"
		Indstrucción.visible = true
		gato.texture = load("res://Microjuegos/Andres/27_Llamar al gato/Sprites/GatoTriste .png")
		gato.position = Vector2(928.0,650.0)
		label.text = label.text + "\ngato malo!!!"
		bien = true

func _process(delta: float) -> void:
	if $TiempoRestante.time_left >= 0:
		$barraDeTiempo.value = $TiempoRestante.time_left

func _on_tiempo_restante_timeout() -> void:
	if not (line_edit.text.to_upper() == nombre.to_upper()):
		$TiempoRestante.stop()
		emit_signal("finished", false)
		emit_signal("microjuego_fallado")

		Indstrucción.text = "Perdiste!"
		Indstrucción.visible = true
		gato.texture = load("res://Microjuegos/Andres/27_Llamar al gato/Sprites/Pose1.png")
		taza.position = Vector2(259.0, 473.0)
		taza.rotation = -18.1
