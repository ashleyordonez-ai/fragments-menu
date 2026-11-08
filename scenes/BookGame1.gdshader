
shader_type canvas_item;

uniform sampler2D screen_texture
    : hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float blur_amount : hint_range(0.0, 3.0) = 1.2;

uniform vec4 tint_color : source_color =
    vec4(0.08, 0.04, 0.10, 0.18);

void fragment() {
    vec4 scene_color = textureLod(
        screen_texture,
        SCREEN_UV,
        blur_amount
    );

    scene_color.rgb = mix(
        scene_color.rgb,
        tint_color.rgb,
        tint_color.a
    );

    COLOR = scene_color;
}
