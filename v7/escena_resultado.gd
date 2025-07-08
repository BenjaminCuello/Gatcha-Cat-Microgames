extends Control

@onready var resultado_label = $VBoxContainer/Label
@onready var ganador_label = $VBoxContainer/Label2

var ganador: String = ""
var victoria: bool = true

func _ready():
	if victoria:
		resultado_label.text = "¡Ganaste! 🎉"
	else:
		resultado_label.text = "¡Perdiste! 😿"

	ganador_label.text = "Ganador: %s" % ganador

func _on_Button_pressed():
	get_tree().change_scene_to_file("res://EscenasGenerales/MenuPrincipal.tscn")
