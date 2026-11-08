shader_type canvas_item;

uniform vec2 scratch_points[128];
uniform int point_count = 0;
uniform float brush_radius = 0.07;

void fragment() {
    vec4 color = texture(TEXTURE, UV);

    for (int i = 0; i < 128; i++) {
        if (i < point_count) {
            float distance_to_point = distance(UV, scratch_points[i]);

            color.a *= smoothstep(
                brush_radius * 0.7,
                brush_radius,
                distance_to_point
            );
        }
    }

    COLOR = color;
}