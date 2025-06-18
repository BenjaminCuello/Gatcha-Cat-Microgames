extends Node2D
signal finished(success)

@onready var MostrarNomGat = $NombreGato
#@onready var escribirNomGat = $EscribirNombre
#@onready var cambiarNombre = $LineEdit
@onready var line_edit = $LineEdit
@onready var label = $EscribirNombre
@onready var Indstrucción = $Instruccion

@onready var gato = $Sprite2D
@onready var taza = $Taza

@onready var timer = $TiempoRestante

@export var TiempoJuego = 5
# Lista de nombres para escoger
var nombres = ["Leo", "Destructor", "Lucas", "Michi", "Diego", "Luna", "Pelusa", "Michifu","Pablonator"]

# Al iniciar el juego
var nombre = nombres[randi() % nombres.size()].to_upper()

func _ready():
	gato.position = Vector2(931.0,499.0)
	taza.position = Vector2(472.0, 645.0)
	taza.rotation = 0
	line_edit.grab_focus()
	MostrarNomGat.text = nombre
	# Conectamos la señal "text_changed" del LineEdit al Label
	line_edit.connect("text_changed", Callable(self, "_on_text_changed"))
	await get_tree().create_timer(1,5).timeout
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
		Indstrucción.text = "Ganaste!"
		Indstrucción.visible = true
		gato.texture = load("res://Microjuegos/Andres/27_Llamar al gato/Sprites/GatoTriste .png")
		gato.position = Vector2(928.0,650.0)
		label.text = label.text + "\ngato malo!!!"
		bien = true

func _process(delta: float) -> void:
	if $TiempoRestante.time_left >= 0:
		$barraDeTiempo.value = $TiempoRestante.time_left
	

# Función para escoger y mostrar un nombre

func _on_tiempo_restante_timeout() -> void:
	if not (line_edit.text.to_upper() == nombre.to_upper()):
		$TiempoRestante.stop()
		emit_signal("finished", false)
		Indstrucción.text = "Perdiste!"
		Indstrucción.visible = true
		gato.texture = load("res://Microjuegos/Andres/27_Llamar al gato/Sprites/Pose1.png")
		taza.position = Vector2(259.0, 473.0)
		taza.rotation = -18.1
