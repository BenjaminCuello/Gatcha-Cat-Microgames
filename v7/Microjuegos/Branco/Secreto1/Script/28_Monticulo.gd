extends StaticBody2D

@onready var sprite = $Sprite2D
var progreso := 0
var progreso_objetivo := 3
var completado := false

var sprites := [
	preload("res://Microjuegos/Branco/Secreto1/Sprite/Monticulo1.png"),
	preload("res://Microjuegos/Branco/Secreto1/Sprite/Monticulo2.png"),
	preload("res://Microjuegos/Branco/Secreto1/Sprite/Monticulo3.png"),
	preload("res://Microjuegos/Branco/Secreto1/Sprite/Monticulo4.png")
]

func _ready():
	# Escala visual del sprite (ajustá según necesites)
	sprite.scale = Vector2(2.5, 2.5)

func cavar():
	if completado:
		return
	progreso += 1
	progreso = clamp(progreso, 0, progreso_objetivo)
	sprite.texture = sprites[progreso]
	if progreso >= progreso_objetivo:
		completado = true

func resetear():
	progreso = 0
	completado = false
	sprite.texture = sprites[0]
