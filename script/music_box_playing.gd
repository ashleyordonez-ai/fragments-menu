
extends Control

@export var glow_position: Vector2 = Vector2(415, 250)
@export var glow_size: Vector2 = Vector2(300, 300)

@export var hold_duration: float = 5.0
@export var fade_duration: float = 0.75

var mechanism_glow: ColorRect
var fade_overlay: ColorRect
var dust_particles: GPUParticles2D


func _ready() -> void:
	_create_dust_particles()
	_create_mechanism_glow()
	_create_fade_overlay()

	# Let the scene appear and the glow pulse for a few seconds.
	await get_tree().create_timer(hold_duration).timeout

	# Fade the entire screen to black.
	await _fade_to_black()



func _create_dust_particles() -> void:
	dust_particles = GPUParticles2D.new()
	dust_particles.name = "DustParticles"

	var viewport_size = get_viewport_rect().size

	# Position the particle emitter at the center.
	dust_particles.position = viewport_size / 2.0

	# Particle settings
	dust_particles.amount = 45
	dust_particles.lifetime = 8.0
	dust_particles.preprocess = 8.0
	dust_particles.explosiveness = 0.0
	dust_particles.randomness = 0.8
	dust_particles.emitting = true

	# Keep particles visible across the screen.
	dust_particles.visibility_rect = Rect2(
		-viewport_size.x / 2.0,
		-viewport_size.y / 2.0,
		viewport_size.x,
		viewport_size.y
	)

	# Create a soft circular particle texture.
	var particle_image = Image.create(
		32,
		32,
		false,
		Image.FORMAT_RGBA8
	)

	for y in range(32):
		for x in range(32):
			var distance = Vector2(
				x - 15.5,
				y - 15.5
			).length() / 15.5

			var alpha = pow(
				max(0.0, 1.0 - distance),
				2.5
			)

			particle_image.set_pixel(
				x,
				y,
				Color(1.0, 0.82, 0.58, alpha)
			)

	var particle_texture = ImageTexture.create_from_image(
		particle_image
	)

	dust_particles.texture = particle_texture

	# Configure particle movement.
	var particle_material = ParticleProcessMaterial.new()

	particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX

	particle_material.emission_box_extents = Vector3(
		viewport_size.x / 2.0,
		viewport_size.y / 2.0,
		1.0
	)

	# Gentle upward movement with some horizontal variation.
	particle_material.direction = Vector3(0.0, -1.0, 0.0)
	particle_material.spread = 35.0

	# Vary the speed so particles don't move identically.
	particle_material.initial_velocity_min = 4.0
	particle_material.initial_velocity_max = 10.0

	# Very light upward force.
	particle_material.gravity = Vector3(0.0, -0.5, 0.0)

	# Different particle sizes.
	particle_material.scale_min = 0.50
	particle_material.scale_max = 1.00

	# Warm champagne-gold color.
	particle_material.color = Color(1.0, 0.88, 0.72, 0.65)

	dust_particles.process_material = particle_material

	# Keep particles above the music box but below the glow.
	dust_particles.z_index = 5

	add_child(dust_particles)



func _create_mechanism_glow() -> void:
	mechanism_glow = ColorRect.new()
	mechanism_glow.name = "MechanismGlow"

	mechanism_glow.position = glow_position
	mechanism_glow.size = glow_size
	mechanism_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mechanism_glow.z_index = 10

	var glow_shader := Shader.new()
	glow_shader.code = """
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.91, 0.79, 0.60, 1.0);
uniform float glow_strength = 0.55;
uniform float pulse_speed = 2.5;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	float dist = length(uv);

	float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);
	float radius = mix(0.27, 0.47, pulse);

	float outer = 1.0 - smoothstep(radius * 0.65, radius + 0.12, dist);
	float inner = 1.0 - smoothstep(radius * 0.20, radius * 0.75, dist);

	float glow = outer * 0.55 + inner * 0.45;
	float brightness = mix(0.45, 1.0, pulse);

	COLOR.rgb = glow_color.rgb;
	COLOR.a = glow * glow_strength * brightness;
}
"""

	var glow_material := ShaderMaterial.new()
	glow_material.shader = glow_shader
	mechanism_glow.material = glow_material

	add_child(mechanism_glow)


func _create_fade_overlay() -> void:
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"

	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.z_index = 100

	# Make the overlay cover the full screen.
	fade_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	add_child(fade_overlay)


func _fade_to_black() -> void:
	var tween := create_tween()

	tween.tween_property(
		fade_overlay,
		"color:a",
		1.0,
		fade_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished
