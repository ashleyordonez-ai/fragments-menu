
extends Area2D

@export var object_texture: Texture2D

@onready var object_sprite: Sprite2D = $ObjectSprite
@onready var interaction_range: Area2D = $InteractionRange

var player_in_range: bool = false


func _ready() -> void:
	# Assign the object texture if one is provided
	if object_texture:
		object_sprite.texture = object_texture

	# Enable mouse detection
	input_pickable = true

	# Connect proximity detection signals
	interaction_range.body_entered.connect(_on_body_entered)
	interaction_range.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		print("PLAYER ENTERED INTERACTION RANGE")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		print("PLAYER LEFT INTERACTION RANGE")


func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("MOUSE CLICK DETECTED")

			if player_in_range:
				print("OBJECT INTERACTION SUCCESSFUL!")
			else:
				print("PLAYER IS TOO FAR AWAY")
