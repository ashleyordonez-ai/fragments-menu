shader_type canvas_item;

uniform vec4 ring_color : source_color = vec4(1.0, 0.72, 0.35, 0.85);

uniform float ring_radius = 0.32;
uniform float ring_thickness = 0.006;

void fragment() {
    vec2 uv = UV - vec2(0.5);

    float dist = length(uv);

    float edge = abs(dist - ring_radius);

    float ring = 1.0 - smoothstep(
        ring_thickness,
        ring_thickness + 0.003,
        edge
    );

    COLOR.rgb = ring_color.rgb;
    COLOR.a = ring_color.a * ring;
}