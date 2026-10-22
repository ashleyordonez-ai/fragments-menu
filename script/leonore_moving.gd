
extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func _ready() -> void:
	if sprite == null:
		push_error("Cannot find AnimatedSprite2D. Check the node path!")
	else:
		sprite.play("front idle")
		print("Movement script is running!")

func _physics_process(_delta: float) -> void:
	if sprite == null:
		return

	var direction := Vector2.ZERO
	var animation_name := "front idle"

	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
		animation_name = "frontWalk"
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
		animation_name = "back walk"
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
		animation_name = "lside walk"
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
		animation_name = "rside walk"

	direction = direction.normalized()

	velocity = direction * speed
	move_and_slide()	

	if direction != Vector2.ZERO:
		print("Moving: ", direction, " Position: ", global_position)

	if sprite.animation != animation_name:
		sprite.play(animation_name)
