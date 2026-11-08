
shader_type canvas_item;

uniform float glitch_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    vec2 uv = UV;

    // Horizontal slices shift briefly during the glitch.
    float slice = floor(UV.y * 32.0);
    float random_value = fract(
        sin(slice * 127.1 + 311.7) * 43758.5453
    );

    if (random_value > 0.72) {
        uv.x += (random_value - 0.5)
            * 0.045 * glitch_amount;
    }

    vec4 tex = texture(TEXTURE, uv);
    COLOR = tex * COLOR;
}