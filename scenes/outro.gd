
extends Control

@onready var background: Control = $background
@onready var quote: Label = $quote
@onready var quote2: Label = $quote2
@onready var quote3: Label = $quote3

const TYPING_SPEED := 13.0
const FINAL_TYPING_SPEED := 11.0

const REVEAL_OFFSET := 12.0
const QUOTE_PAUSE := 0.8
const GLOW_DURATION := 1.4

const FINAL_HOLD := 2.5
const DISSOLVE_DURATION := 4.0


func _ready() -> void:
	quote.visible = false
	quote2.visible = false
	quote3.visible = false

	animate_background()
	play_outro()


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

	# FINAL QUOTE
	await show_quote(quote3, FINAL_TYPING_SPEED)
	await screen_glow()

	# Let the final message linger
	await get_tree().create_timer(FINAL_HOLD).timeout

	# Slowly dissolve the final message
	await dissolve_final_quote()

	# End the game immediately after dissolving
	get_tree().quit()


func show_quote(label: Label, typing_speed: float) -> void:
	var original_position := label.position
	var original_modulate := label.modulate

	var total_characters := label.get_total_character_count()
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

	tween.tween_property(
		label,
		"visible_characters",
		total_characters,
		typing_duration
	).set_trans(Tween.TRANS_LINEAR)

	tween.tween_property(
		label,
		"modulate:a",
		original_modulate.a,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(
		label,
		"position",
		original_position,
		1.2
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

	label.visible_characters = -1
	label.position = original_position
	label.modulate = original_modulate


func hide_quote(label: Label) -> void:
	var tween := create_tween()

	tween.tween_property(
		label,
		"modulate:a",
		0.0,
		1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished

	label.visible = false


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


func dissolve_final_quote() -> void:
	var material := quote3.material as ShaderMaterial

	if material == null:
		push_error("quote3 needs a ShaderMaterial with the text melt shader.")
		return

	# Start the melting effect
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
