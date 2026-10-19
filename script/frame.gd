
extends TextureRect

@export var animation_duration: float = 0.8
@export var start_scale: float = 0.88
@export var fade_duration: float = 0.65

func _ready() -> void:
	# Animate around the center of the frame.
	pivot_offset = size / 2.0

	# Remember the original scale.
	var original_scale: Vector2 = scale

	# Begin slightly smaller and transparent.
	scale = original_scale * start_scale
	modulate.a = 0.0

	# Animate the frame's scale and fade together.
	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		self,
		"scale",
		original_scale,
		animation_duration
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"modulate:a",
		1.0,
		fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
