extends Control

@onready var chapter_label: Label = $chap4
@onready var subtitle_label: Label = $Subtitle
@onready var continue_button: Button = $ContinueButton

const NEXT_SCENE := "res://scenes/Chapter 4/Chapter 4_Hospital-Scene.tscn"
const FADE_DURATION: float = 0.8

var original_label_position: Vector2
var original_label_color: Color
var transition_running: bool = false


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
	while is_inside_tree() and not transition_running:
		await get_tree().create_timer(2.5).timeout

		if not is_inside_tree() or transition_running:
			return

		await _play_glitch_effect()


func _play_glitch_effect() -> void:
	if transition_running:
		return

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

	if transition_running:
		return

	# Second, smaller glitch burst.
	await get_tree().create_timer(0.08).timeout

	if not is_inside_tree() or transition_running:
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


# =====================================
# FADE-OUT TRANSITION
# =====================================

func fade_to_black() -> void:
	var fade_overlay := ColorRect.new()
	fade_overlay.name = "TransitionFade"
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.offset_left = 0
	fade_overlay.offset_top = 0
	fade_overlay.offset_right = 0
	fade_overlay.offset_bottom = 0

	fade_overlay.z_as_relative = false
	fade_overlay.z_index = 4096

	add_child(fade_overlay)

	var fade_tween := create_tween()

	fade_tween.tween_property(
		fade_overlay,
		"color",
		Color.BLACK,
		FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await fade_tween.finished


# =====================================
# CONTINUE BUTTON
# =====================================

func _on_continue_pressed() -> void:
	if transition_running:
		return

	print("CONTINUE BUTTON PRESSED!")

	if not ResourceLoader.exists(NEXT_SCENE):
		push_error("SCENE NOT FOUND: " + NEXT_SCENE)
		return

	transition_running = true
	continue_button.disabled = true

	# Fade out before changing scenes.
	await fade_to_black()

	var error := get_tree().change_scene_to_file(NEXT_SCENE)

	if error != OK:
		push_error("FAILED TO LOAD NEXT SCENE. ERROR: " + str(error))
