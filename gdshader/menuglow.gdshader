
shader_type canvas_item;

uniform vec4 glow_color : source_color =
    vec4(0.58, 0.30, 1.0, 1.0);

uniform float glow_strength : hint_range(0.0, 2.0) = 0.6;

void fragment() {
    vec2 texel = TEXTURE_PIXEL_SIZE;

    float alpha = 0.0;

    // Sample around the logo's transparent edges.
    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            float distance_from_center =
                length(vec2(float(x), float(y)));

            if (distance_from_center > 0.0 &&
                distance_from_center <= 4.0) {
                float sample_alpha = texture(
                    TEXTURE,
                    UV + vec2(float(x), float(y)) * texel
                ).a;

                alpha = max(alpha, sample_alpha);
            }
        }
    }

    float original_alpha = texture(TEXTURE, UV).a;
    float halo = max(alpha - original_alpha, 0.0);

    COLOR = vec4(
        glow_color.rgb,
        halo * glow_color.a * glow_strength
    );
}