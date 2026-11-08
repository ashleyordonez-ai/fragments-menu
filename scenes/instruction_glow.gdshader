
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.84, 0.71, 0.43, 1.0);

uniform float glow_strength : hint_range(0.0, 3.0) = 1.2;
uniform float glow_radius : hint_range(1.0, 30.0) = 10.0;
uniform float border_width : hint_range(1.0, 5.0) = 1.5;
uniform float corner_radius : hint_range(0.0, 20.0) = 6.0;
uniform float border_inset : hint_range(1.0, 30.0) = 12.0;

uniform vec2 rect_size = vec2(744.0, 92.0);

uniform float rotation_speed : hint_range(0.1, 5.0) = 1.0;
uniform float highlight_width : hint_range(0.05, 1.0) = 0.22;
uniform float highlight_strength : hint_range(0.0, 4.0) = 2.0;

float rounded_box_sdf(vec2 p, vec2 half_size, float radius) {
    vec2 q = abs(p) - half_size + vec2(radius);

    return length(max(q, vec2(0.0)))
        + min(max(q.x, q.y), 0.0) - radius;
}

void fragment() {
    vec2 p = (UV - vec2(0.5)) * rect_size;

    vec2 half_size = rect_size * 0.5 - vec2(border_inset);

    float d = rounded_box_sdf(p, half_size, corner_radius);

    // Permanent border
    float border = 1.0 - smoothstep(
        border_width * 0.5,
        border_width * 0.5 + 1.0,
        abs(d)
    );

    // Permanent soft glow
    float glow = exp(
        -max(abs(d) - border_width * 0.5, 0.0)
        / max(glow_radius, 1.0)
    );

    // Moving highlight traveling around the border
    float angle = atan(p.y, p.x);
    float moving_angle = angle - TIME * rotation_speed;

    float highlight = exp(
        -pow(moving_angle - round(moving_angle / 6.28318) * 6.28318, 2.0)
        / (2.0 * highlight_width * highlight_width)
    );

    float moving_glow = highlight * exp(
        -max(abs(d) - border_width * 0.5, 0.0)
        / max(glow_radius * 1.5, 1.0)
    );

    float alpha = max(
        border * 0.85,
        glow * glow_strength * 0.35
    );

    alpha += moving_glow * highlight_strength * 0.65;

    COLOR = vec4(glow_color.rgb, clamp(alpha, 0.0, 1.0));
}
