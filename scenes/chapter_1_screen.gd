
extends Control

@onready var chapter_label: Label = $chap1
@onready var subtitle_label: Label = $Subtitle
@onready var continue_button: Button = $ContinueButton

const NEXT_SCENE := "res://scenes/Chapter 1/Chapter 1_SceneBG.tscn"

var original_label_position: Vector2
var original_label_color: Color


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)

	# Save the exact editor settings.
	original_label_position = chapter_label.position
	original_label_color = chapter_label.modulate

	_play_intro_animation()


func _play_intro_animation() -> void:
	chapter_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	continue_button.modulate.a = 0.0

	await get_tree().create_timer(0.15).timeout

	# Chapter title appears.
	var title_tween := create_tween()
	title_tween.tween_property(
		chapter_label,
		"modulate:a",
		1.0,
		0.35
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	await title_tween.finished

	# Subtitle appears.
	await get_tree().create_timer(0.15).timeout

	var subtitle_tween := create_tween()
	subtitle_tween.tween_property(
		subtitle_label,
		"modulate:a",
		1.0,
		0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await subtitle_tween.finished

	# Continue button appears.
	await get_tree().create_timer(0.25).timeout

	var button_tween := create_tween()
	button_tween.tween_property(
		continue_button,
		"modulate:a",
		1.0,
		0.4
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await button_tween.finished

	_start_title_glitch()


func _start_title_glitch() -> void:
	while is_inside_tree():
		await get_tree().create_timer(2.5).timeout

		if not is_inside_tree():
			return

		_play_glitch_effect()


func _play_glitch_effect() -> void:
	# First glitch burst.
	var glitch := create_tween()

	glitch.tween_property(
		chapter_label,
		"position",
		original_label_position + Vector2(10, 0),
		0.045
	)

	glitch.parallel().tween_property(
		chapter_label,
		"modulate",
		Color(0.3, 0.9, 1.0, 0.35),
		0.045
	)

	glitch.tween_property(
		chapter_label,
		"position",
		original_label_position + Vector2(-9, 2),
		0.045
	)

	glitch.parallel().tween_property(
		chapter_label,
		"modulate",
		Color(1.0, 0.3, 0.75, 0.5),
		0.045
	)

	glitch.tween_property(
		chapter_label,
		"position",
		original_label_position + Vector2(5, -1),
		0.035
	)

	glitch.tween_property(
		chapter_label,
		"position",
		original_label_position,
		0.055
	)

	glitch.parallel().tween_property(
		chapter_label,
		"modulate",
		original_label_color,
		0.055
	)

	await glitch.finished

	# Brief pause before a second, smaller glitch.
	await get_tree().create_timer(0.08).timeout

	if not is_inside_tree():
		return

	var second_glitch := create_tween()

	second_glitch.tween_property(
		chapter_label,
		"position",
		original_label_position + Vector2(-7, 0),
		0.035
	)

	second_glitch.parallel().tween_property(
		chapter_label,
		"modulate:a",
		0.25,
		0.035
	)

	second_glitch.tween_property(
		chapter_label,
		"position",
		original_label_position + Vector2(6, 1),
		0.035
	)

	second_glitch.tween_property(
		chapter_label,
		"position",
		original_label_position,
		0.05
	)

	second_glitch.parallel().tween_property(
		chapter_label,
		"modulate",
		original_label_color,
		0.05
	)

	await second_glitch.finished


func _on_continue_pressed() -> void:
	print("CONTINUE BUTTON PRESSED!")

	if not ResourceLoader.exists(NEXT_SCENE):
		push_error("SCENE NOT FOUND: " + NEXT_SCENE)
		return

	var error := get_tree().change_scene_to_file(NEXT_SCENE)

	if error != OK:
		push_error("FAILED TO LOAD NEXT SCENE. ERROR: " + str(error))
