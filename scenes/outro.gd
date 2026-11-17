
extends Control

@onready var background: Control = $background
@onready var quote: Label = $quote
@onready var quote2: Label = $quote2
@onready var quote3: Label = $quote3


# =====================================
# ANIMATION SETTINGS
# =====================================

const TYPING_SPEED := 13.0
const FINAL_TYPING_SPEED := 11.0

const REVEAL_OFFSET := 12.0
const QUOTE_PAUSE := 0.8
const GLOW_DURATION := 1.4

const FINAL_HOLD := 2.5
const DISSOLVE_DURATION := 4.0

const ENDING_HOLD := 2.0
const ENDING_FADE_DURATION := 1.0

const ENDING_FONT_SIZE := 100
const SCREEN_FADE_DURATION := 1.8

const MAIN_MENU_SCENE := "res://scenes/Main Menu/menu.tscn"

var ending_label: Label
var transition_overlay: ColorRect


# =====================================
# INITIALIZE
# =====================================

func _ready() -> void:

	quote.visible = false
	quote2.visible = false
	quote3.visible = false

	create_ending_label()
	create_transition_overlay()

	animate_background()
	play_outro()


# =====================================
# CREATE DYNAMIC ENDING LABEL
# =====================================

func create_ending_label() -> void:

	ending_label = Label.new()
	ending_label.name = "EndingLabel"
	ending_label.text = "THE END"

	ending_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ending_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	ending_label.set_anchors_preset(Control.PRESET_CENTER)
	ending_label.position = Vector2(-350, -65)
	ending_label.size = Vector2(700, 130)

	# Copy font styling from quote3
	ending_label.add_theme_font_override(
		"font",
		quote3.get_theme_font("font")
	)

	# Set THE END font size to 100
	ending_label.add_theme_font_size_override(
		"font_size",
		ENDING_FONT_SIZE
	)

	ending_label.add_theme_color_override(
		"font_color",
		quote3.get_theme_color("font_color")
	)

	ending_label.visible = false
	ending_label.visible_characters = 0
	ending_label.modulate.a = 0.0
	ending_label.z_index = 100

	add_child(ending_label)


# =====================================
# CREATE SCREEN TRANSITION OVERLAY
# =====================================

func create_transition_overlay() -> void:

	transition_overlay = ColorRect.new()
	transition_overlay.name = "TransitionOverlay"

	transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	transition_overlay.offset_left = 0
	transition_overlay.offset_top = 0
	transition_overlay.offset_right = 0
	transition_overlay.offset_bottom = 0

	transition_overlay.color = Color.BLACK
	transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	transition_overlay.visible = true
	transition_overlay.modulate.a = 0.0
	transition_overlay.z_index = 4096

	add_child(transition_overlay)


# =====================================
# OUTRO SEQUENCE
# =====================================

func play_outro() -> void:

	# FIRST QUOTE
	await show_quote(quote, TYPING_SPEED)
	await screen_glow()
	await hide_quote(quote)

	await get_tree().create_timer(QUOTE_PAUSE).timeout

	# SECOND QUOTE
	await show_quote(quote2, TYPING_SPEED)
	await screen_glow()
	await hide_quote(quote2)

	await get_tree().create_timer(QUOTE_PAUSE).timeout

	# THIRD QUOTE
	await show_quote(quote3, FINAL_TYPING_SPEED)
	await screen_glow()

	await get_tree().create_timer(FINAL_HOLD).timeout

	await dissolve_final_quote()

	# THE END
	await get_tree().create_timer(QUOTE_PAUSE).timeout

	await show_quote(ending_label, FINAL_TYPING_SPEED)
	await screen_glow()

	await get_tree().create_timer(ENDING_HOLD).timeout

	await hide_quote(ending_label)

	# FADE OUT BEFORE RETURNING TO MAIN MENU
	await fade_to_main_menu()

	go_to_main_menu()


# =====================================
# SHOW QUOTE / ENDING
# =====================================

func show_quote(label: Label, typing_speed: float) -> void:

	var original_position := label.position
	var original_modulate := label.modulate

	var total_characters := label.get_total_character_count()

	if total_characters == 0:
		push_error("LABEL HAS NO TEXT: " + label.name)
		return

	var target_modulate := original_modulate
	target_modulate.a = 1.0

	var typing_duration := maxf(
		float(total_characters) / typing_speed,
		1.0
	)

	label.visible = true
	label.visible_characters = 0
	label.position = original_position + Vector2(0, REVEAL_OFFSET)
	label.modulate.a = 0.0

	var tween := create_tween()
	tween.set_parallel(true)

	# Typing effect
	tween.tween_property(
		label,
		"visible_characters",
		total_characters,
		typing_duration
	).set_trans(Tween.TRANS_LINEAR)

	# Fade in
	tween.tween_property(
		label,
		"modulate:a",
		1.0,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# Slight upward movement
	tween.tween_property(
		label,
		"position",
		original_position,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	label.visible_characters = -1
	label.position = original_position
	label.modulate = target_modulate


# =====================================
# HIDE QUOTE / ENDING
# =====================================

func hide_quote(label: Label) -> void:

	var tween := create_tween()

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		ENDING_FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	label.visible = false


# =====================================
# SCREEN GLOW
# =====================================

func screen_glow() -> void:

	var original_color := modulate

	var glow_tween := create_tween()

	glow_tween.tween_property(
		self,
		"modulate",
		Color(1.06, 1.02, 1.10, original_color.a),
		GLOW_DURATION * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	glow_tween.tween_property(
		self,
		"modulate",
		original_color,
		GLOW_DURATION * 0.5
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await glow_tween.finished


# =====================================
# DISSOLVE EFFECT
# =====================================

func dissolve_final_quote() -> void:

	var material := quote3.material as ShaderMaterial

	if material == null:
		push_error("quote3 needs a ShaderMaterial with the text melt shader.")
		return

	material.set_shader_parameter("melt_amount", 0.0)

	var melt_tween := create_tween()

	melt_tween.tween_method(
		func(value: float):
			material.set_shader_parameter("melt_amount", value),
		0.0,
		1.0,
		DISSOLVE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await melt_tween.finished

	quote3.visible = false


# =====================================
# FADE OUT TO MAIN MENU
# =====================================

func fade_to_main_menu() -> void:

	transition_overlay.visible = true
	transition_overlay.modulate.a = 0.0

	var fade_tween := create_tween()

	fade_tween.tween_property(
		transition_overlay,
		"modulate:a",
		1.0,
		SCREEN_FADE_DURATION
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await fade_tween.finished


# =====================================
# BACKGROUND ANIMATION
# =====================================

func animate_background() -> void:

	var original_position := background.position

	background.pivot_offset = background.size / 2.0
	background.scale = Vector2(1.06, 1.06)

	var bg_tween := create_tween()
	bg_tween.set_loops()

	bg_tween.tween_property(
		background,
		"position",
		original_position + Vector2(-10, -6),
		12.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	bg_tween.tween_property(
		background,
		"position",
		original_position + Vector2(10, 6),
		12.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


# =====================================
# RETURN TO MAIN MENU
# =====================================

func go_to_main_menu() -> void:

	print("OUTRO COMPLETED")
	print("RETURNING TO MAIN MENU...")

	if not ResourceLoader.exists(MAIN_MENU_SCENE):
		push_error("MAIN MENU SCENE NOT FOUND: " + MAIN_MENU_SCENE)
		return

	var error := get_tree().change_scene_to_file(MAIN_MENU_SCENE)

	if error != OK:
		push_error("FAILED TO LOAD MAIN MENU. ERROR: " + str(error))
