extends TextureRect

@export var min_glitch_interval: float = 0.4
@export var max_glitch_interval: float = 1.5

@export var rotation_nudge: float = 1.2

@export var nudge_duration: float = 0.06
@export var settle_duration: float = 0.035

var original_rotation: float
var glitch_tween: Tween


func _ready() -> void:
	original_rotation = rotation

	await get_tree().create_timer(
		randf_range(min_glitch_interval, max_glitch_interval)
	).timeout

	while is_inside_tree():
		await glitch_once()

		await get_tree().create_timer(
			randf_range(min_glitch_interval, max_glitch_interval)
		).timeout


func glitch_once() -> void:
	var direction := 1.0 if randf() > 0.5 else -1.0

	glitch_tween = create_tween()

	# Tiny attempt to turn
	glitch_tween.tween_property(
		self,
		"rotation",
		original_rotation + deg_to_rad(rotation_nudge * direction),
		nudge_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Catch and jerk slightly backward
	glitch_tween.tween_property(
		self,
		"rotation",
		original_rotation - deg_to_rad(rotation_nudge * 0.35 * direction),
		nudge_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Return smoothly to its original position
	glitch_tween.tween_property(
		self,
		"rotation",
		original_rotation,
		settle_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await glitch_tween.finished
