
shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 2.0;
uniform float left_edge : hint_range(0.0, 1.0) = 0.52;
uniform float dim_amount : hint_range(0.0, 0.6) = 0.10;

uniform sampler2D screen_texture :
    hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 px = SCREEN_PIXEL_SIZE * blur_amount;

    vec4 original = texture(screen_texture, uv);
    vec4 blurred = original * 0.28;

    blurred += texture(screen_texture, uv + vec2(px.x, 0.0)) * 0.12;
    blurred += texture(screen_texture, uv - vec2(px.x, 0.0)) * 0.12;
    blurred += texture(screen_texture, uv + vec2(0.0, px.y)) * 0.12;
    blurred += texture(screen_texture, uv - vec2(0.0, px.y)) * 0.12;
    blurred += texture(screen_texture, uv + px) * 0.06;
    blurred += texture(screen_texture, uv - px) * 0.06;
    blurred += texture(screen_texture, uv + vec2(px.x, -px.y)) * 0.06;
    blurred += texture(screen_texture, uv + vec2(-px.x, px.y)) * 0.06;

    if (uv.x < left_edge) {
        COLOR = vec4(
            mix(blurred.rgb, vec3(0.0), dim_amount),
            1.0
        );
    } else {
        COLOR = original;
    }
}
