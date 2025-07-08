extends Control

@onready var label_ganador = $VBoxContainer/LabelGanador
@onready var label_stats = $VBoxContainer/LabelStats
@onready var boton_salir = $VBoxContainer/BotonSalir

func mostrar_resultados(ganador: String, stats_text: String):
	label_ganador.text = "Ganador: " + ganador
	label_stats.text = stats_text

func _ready():
	boton_salir.pressed.connect(_on_BotonSalir_pressed)

func _on_BotonSalir_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/MenuPrincipal.tscn")
