
extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("front idle")


func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	var animation_name := "front idle"

	# W = forward
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1
		animation_name = "frontWalk"

	# S = backward
	if Input.is_key_pressed(KEY_S):
		direction.y += 1
		animation_name = "back walk"

	# A = left
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1
		animation_name = "lside walk"

	# D = right
	if Input.is_key_pressed(KEY_D):
		direction.x += 1
		animation_name = "rside walk"

	# Prevent faster diagonal movement
	direction = direction.normalized()

	# Move the character and handle collisions
	velocity = direction * speed
	move_and_slide()

	# Play the correct animation
	if sprite.animation != animation_name:
		sprite.play(animation_name)
		
