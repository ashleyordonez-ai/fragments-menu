
shader_type canvas_item;

uniform float melt_amount : hint_range(0.0, 1.0) = 0.0;
uniform float melt_strength = 0.30;

float random_value(float x) {
	return fract(sin(x * 127.1) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;

	float column = floor(UV.x * 55.0);
	float random_offset = random_value(column);

	float start = 0.12 + random_offset * 0.55;

	float progress = clamp(
		(melt_amount - start) / (1.0 - start),
		0.0,
		1.0
	);

	float drip = smoothstep(0.0, 1.0, progress);

	float drip_length = drip * melt_strength *
		(0.35 + random_offset * 0.9);

	// Pull the text downward
	vec2 distorted_uv = uv - vec2(0.0, drip_length);

	vec4 tex_color = texture(TEXTURE, distorted_uv) * COLOR;

	// Gradually dissolve the melting text
	float opacity = 1.0 - smoothstep(0.35, 1.0, melt_amount);

	tex_color.a *= opacity;

	COLOR = tex_color;
}
