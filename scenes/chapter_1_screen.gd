
extends Control

@onready var chapter_label: Label = $chap1

#const NEXT_SCENE := "res://scenes/gameplay_intro/chap1_intro.tscn"

# Animation settings
const POP_DURATION := 0.8
const GLITCH_DURATION := 2.0
const FADE_DURATION := 0.8

var original_position: Vector2
var original_modulate: Color


func _ready() -> void:
	original_position = chapter_label.position
	original_modulate = chapter_label.modulate

	# Initial state
	chapter_label.position.y = original_position.y + 18.0
	chapter_label.modulate.a = 0.0

	play_chapter_animation()


func play_chapter_animation() -> void:

	# SOFT REVEAL
	var reveal_tween = create_tween()
	reveal_tween.set_parallel(true)

	reveal_tween.tween_property(
		chapter_label,
		"position",
		original_position,
		POP_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	reveal_tween.tween_property(
		chapter_label,
		"modulate:a",
		1.0,
		POP_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await reveal_tween.finished

	# SHORT PAUSE
	await get_tree().create_timer(0.5).timeout

	# SLOW, SUBTLE COLOR GLITCH
	var elapsed := 0.0

	var lavender_tint := Color(0.94, 0.86, 0.98, 1.0)
	var cyan_tint := Color(0.86, 0.94, 0.97, 1.0)

	while elapsed < GLITCH_DURATION:

		# Slowly transition to a muted color
		var glitch_color = lavender_tint if randf() > 0.5 else cyan_tint

		var color_tween = create_tween()
		color_tween.set_parallel(true)

		color_tween.tween_property(
			chapter_label,
			"modulate",
			glitch_color,
			0.35
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		color_tween.tween_property(
			chapter_label,
			"position",
			original_position + Vector2(randf_range(-1.0, 1.0), 0),
			0.35
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		await color_tween.finished

		# Slowly return to original appearance
		var restore_tween = create_tween()
		restore_tween.set_parallel(true)

		restore_tween.tween_property(
			chapter_label,
			"modulate",
			original_modulate,
			0.45
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		restore_tween.tween_property(
			chapter_label,
			"position",
			original_position,
			0.45
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		await restore_tween.finished

		elapsed += 0.8

	# RESTORE ORIGINAL APPEARANCE
	chapter_label.position = original_position
	chapter_label.modulate = original_modulate

	# FADE OUT
	var fade_tween = create_tween()

	fade_tween.tween_property(
		chapter_label,
		"modulate:a",
		0.0,
		FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await fade_tween.finished

	# TRANSITION
	#get_tree().change_scene_to_file(NEXT_SCENE)
