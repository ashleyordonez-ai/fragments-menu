extends Sprite2D

var glitch_material: ShaderMaterial
var base_position: Vector2

var menu_is_idle: bool = false
var is_glitching: bool = false


func _ready() -> void:
	base_position = position
	glitch_material = material as ShaderMaterial

	if glitch_material:
		glitch_material.set_shader_parameter("glitch_amount", 0.0)

	# Pause before the first glitch
	await get_tree().create_timer(0.5).timeout

	# Strong startup glitch
	await play_startup_glitch()

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
