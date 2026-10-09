
extends Sprite2D

@onready var glow: Sprite2D = get_node("../LogoGlow")

var glitch_material: ShaderMaterial
var base_position: Vector2

var menu_is_idle: bool = false
var is_glitching: bool = false


func _ready() -> void:
	base_position = position
	glitch_material = material as ShaderMaterial

	# Start invisible
	modulate.a = 0.0
	glow.modulate.a = 0.0

	if glitch_material:
		glitch_material.set_shader_parameter("glitch_amount", 0.0)

	# Start slightly below the original position
	position = base_position + Vector2(0, 12)

	# Fade in and settle into position
	var intro_tween = create_tween()
	intro_tween.set_parallel(true)

	intro_tween.tween_property(
		self, "modulate:a", 1.0, 0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	intro_tween.tween_property(
		self, "position", base_position, 0.8
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	await intro_tween.finished

	# Pause before the first glitch
	await get_tree().create_timer(0.5).timeout

	# Strong startup glitch
	await play_startup_glitch()

	# Start the violet glow pulse
	pulse_glow()

	# Begin recurring idle glitches
	menu_is_idle = true
	start_idle_glitch_loop()


func set_glitch_amount(value: float) -> void:
	if glitch_material:
		glitch_material.set_shader_parameter(
			"glitch_amount", value
		)


func play_startup_glitch() -> void:
	if is_glitching:
		return

	is_glitching = true

	var tween = create_tween()

	tween.tween_method(
		set_glitch_amount, 0.0, 1.2, 0.06
	)
	tween.tween_method(
		set_glitch_amount, 1.2, 0.0, 0.11
	)

	await tween.finished

	set_glitch_amount(0.0)
	position = base_position
	is_glitching = false


func pulse_glow() -> void:
	if not is_instance_valid(glow):
		return

	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		glow, "modulate:a", 0.7, 1.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		glow, "modulate:a", 0.25, 1.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func start_idle_glitch_loop() -> void:
	while is_inside_tree():
		# Random delay between 3 and 5 seconds
		await get_tree().create_timer(
			randf_range(3.0, 5.0)
		).timeout

		if not is_inside_tree():
			return

		if not menu_is_idle or is_glitching:
			continue

		await play_idle_glitch()


func play_idle_glitch() -> void:
	if is_glitching:
		return

	is_glitching = true

	var tween = create_tween()

	# More noticeable, quick glitch
	tween.tween_method(
		set_glitch_amount, 0.0, 0.5, 0.045
	)
	tween.tween_method(
		set_glitch_amount, 0.5, 0.0, 0.085
	)

	await tween.finished

	set_glitch_amount(0.0)
	position = base_position
	is_glitching = false
