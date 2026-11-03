shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.55, 0.32, 0.20, 1.0);
uniform vec4 moving_glow_color : source_color = vec4(1.0, 0.78, 0.42, 1.0);

uniform float border_thickness : hint_range(0.01, 0.15) = 0.06;
uniform float glow_width : hint_range(0.05, 0.5) = 0.22;
uniform float glow_speed : hint_range(0.1, 3.0) = 0.65;


void fragment() {
    vec2 uv = UV;

    // Distance from the edge of the panel
    float edge_x = min(uv.x, 1.0 - uv.x);
    float edge_y = min(uv.y, 1.0 - uv.y);
    float edge = min(edge_x, edge_y);

    // Permanent, subtle antique-gold border
    float border = 1.0 - smoothstep(
        border_thickness,
        border_thickness + 0.01,
        edge
    );

    // Position around the rectangular perimeter
    float perimeter;

    if (uv.y < 0.02) {
        perimeter = uv.x;
    } else if (uv.x > 0.98) {
        perimeter = 1.0 + uv.y;
    } else if (uv.y > 0.98) {
        perimeter = 2.0 + (1.0 - uv.x);
    } else {
        perimeter = 3.0 + (1.0 - uv.y);
    }

    // One bright highlight moving around the frame
    float position = fract(TIME * glow_speed);
    float distance = abs(perimeter / 4.0 - position);
    distance = min(distance, 1.0 - distance);

    float moving_glow = 1.0 - smoothstep(
        0.0,
        glow_width,
        distance
    );

    // Combine fixed border and traveling highlight
    vec4 final_color = mix(
        border_color,
        moving_glow_color,
        moving_glow
    );

    COLOR = final_color;
    COLOR.a = border * (0.85 + moving_glow * 0.15);
}