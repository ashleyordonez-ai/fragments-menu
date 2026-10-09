
extends TextureRect

@export var glitch_distance: float = 2.0
@export var glitch_speed: float = 0.045

var original_position: Vector2
var hovering: bool = false
var glitch_tween: Tween

func _ready() -> void:
	original_position = position
	mouse_filter = Control.MOUSE_FILTER_STOP

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	hovering = true
	_start_glitch()


func _on_mouse_exited() -> void:
	hovering = false

	if glitch_tween and glitch_tween.is_running():
		glitch_tween.kill()

	position = original_position


func _start_glitch() -> void:
	if glitch_tween and glitch_tween.is_running():
		glitch_tween.kill()

	glitch_tween = create_tween()

	while hovering:
		glitch_tween.tween_property(
			self,
			"position",
			original_position + Vector2(glitch_distance, 0),
			glitch_speed
		)

		glitch_tween.tween_property(
			self,
			"position",
			original_position - Vector2(glitch_distance, 0),
			glitch_speed
		)

		glitch_tween.tween_property(
			self,
			"position",
			original_position,
			glitch_speed
		)

		await glitch_tween.finished

		if hovering:
			await get_tree().create_timer(0.25).timeout
