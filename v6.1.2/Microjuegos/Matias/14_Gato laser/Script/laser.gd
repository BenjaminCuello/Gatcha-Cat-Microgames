extends Area2D

@onready var sprite = $LaserSprite

#func _ready():
	# Configurar sprite del láser solo si existe
	#if sprite:
	#	sprite.modulate = Color.RED
	# Si usas ColorRect en lugar de Sprite2D:
	# if sprite:
	#     sprite.color = Color.RED
	#     sprite.size = Vector2(20, 20)
