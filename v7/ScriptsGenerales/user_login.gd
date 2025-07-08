extends Control

@onready var name_input := $VBoxContainer/name_input
@onready var connect_button := $VBoxContainer/connect_button

func _ready():
	# Este connect ya no es necesario si lo hiciste con la señal desde el editor
	# connect_button.pressed.connect(_on_connect_pressed)
	pass

func _on_connect_button_pressed() -> void:
	var username = name_input.text.strip_edges()
	if username == "":
		show_alert("Por favor ingresa un nombre válido.")
		return
	Global.username = username
	get_tree().change_scene_to_file("res://EscenasGenerales/Menus/Online/chat-window.tscn")

func show_alert(msg):
	var dialog := AcceptDialog.new()
	dialog.dialog_text = msg
	add_child(dialog)
	dialog.popup_centered()
