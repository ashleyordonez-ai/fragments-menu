
extends Area2D

@export var object_texture: Texture2D

@onready var object_sprite: Sprite2D = $ObjectSprite

func _ready() -> void:
	object_sprite.texture = object_texture
