
extends Area2D

@export var object_texture: Texture2D

@onready var object_sprite: Sprite2D = $ObjectSprite
@onready var interaction_range: Area2D = $InteractionRange

var player_in_range: bool = false


func _ready() -> void:
	print("TEST: OBJECT SCRIPT IS RUNNING")

	object_sprite.texture = object_texture

	interaction_range.body_entered.connect(_on_body_entered)
	interaction_range.body_exited.connect(_on_body_exited)

	input_pickable = true

	print("InteractionRange monitoring: ", interaction_range.monitoring)
	print("InteractionRange mask: ", interaction_range.collision_mask)


func _on_body_entered(body: Node2D) -> void:
	print("Something entered InteractionRange: ", body.name)
	print("Is player group: ", body.is_in_group("player"))

	if body.is_in_group("player"):
		player_in_range = true
		print("PLAYER IS NEAR THE OBJECT!")


func _on_body_exited(body: Node2D) -> void:
	print("Something exited InteractionRange: ", body.name)

	if body.is_in_group("player"):
		player_in_range = false
		print("PLAYER LEFT THE OBJECT!")


func _input_event(
	_viewport: Viewport,
	event: InputEvent,
	_shape_idx: int
) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:

			print("MOUSE CLICK DETECTED!")

			if not player_in_range:
				print("Player is too far away!")
				return

			interact()


func interact() -> void:
	print("OBJECT CLICKED! INTERACTION STARTED!")
