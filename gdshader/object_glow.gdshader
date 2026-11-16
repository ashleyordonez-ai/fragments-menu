
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.65, 0.15, 1.0);
uniform float outline_size = 3.0;
uniform float glow_strength = 0.0;

void vertex() {
    VERTEX += (UV - vec2(0.5)) * outline_size * 2.0;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    float nearby_alpha = 0.0;

    for (int x = -4; x <= 4; x++) {
        for (int y = -4; y <= 4; y++) {
            vec2 offset = vec2(float(x), float(y));
            
            float sample_alpha = texture(
                TEXTURE,
                UV + offset * TEXTURE_PIXEL_SIZE * outline_size
            ).a;

            nearby_alpha = max(nearby_alpha, sample_alpha);
        }
    }

    float outline = max(nearby_alpha - tex.a, 0.0);

    vec3 final_color = tex.rgb + glow_color.rgb * outline * glow_strength;
    float final_alpha = max(tex.a, outline * glow_strength);

    COLOR = vec4(final_color, final_alpha);
}
