
shader_type canvas_item;

uniform vec2 rect_top_left = vec2(0.3, 0.3);
uniform vec2 rect_bottom_right = vec2(0.7, 0.7);

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float screen_aspect = 1.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 p = uv * vec2(screen_aspect, 1.0);

    vec2 tl = rect_top_left * vec2(screen_aspect, 1.0);
    vec2 br = rect_bottom_right * vec2(screen_aspect, 1.0);

    // Distance outside the picture rectangle
    vec2 outside = max(max(tl - p, p - br), vec2(0.0));
    float dist = length(outside);

    // Phase 1: Expanding light from the entire border
    float radius = progress * 2.0;

    float ray_front = 1.0 - smoothstep(
        radius - 0.12,
        radius + 0.06,
        dist
    );

    // Keep the photograph itself untouched during phase 1
    float outside_picture = step(0.001, dist);

    float angle = atan(
        p.y - (tl.y + br.y) * 0.5,
        p.x - (tl.x + br.x) * 0.5
    );

    float rays = pow(
        max(0.0, sin(angle * 24.0 + sin(angle * 8.0) * 2.0)),
        10.0
    );

    float ray_alpha = ray_front * outside_picture;

    vec3 gold = vec3(0.88, 0.53, 0.12);
    vec3 bright_gold = vec3(1.0, 0.76, 0.32);
    vec3 sunlight = vec3(1.0, 0.93, 0.76);

    vec3 ray_color = mix(gold, bright_gold, rays);
    ray_color = mix(ray_color, sunlight, rays * 0.65);

    // Phase 2: Full-screen golden flash
    float full_flash = smoothstep(0.72, 0.88, progress);

    vec3 final_gold = mix(
        bright_gold,
        sunlight,
        smoothstep(0.92, 1.0, progress)
    );

    vec3 final_color = mix(ray_color, final_gold, full_flash);

    float alpha = max(
        ray_alpha * (0.75 + rays * 0.25),
        full_flash
    );

    COLOR = vec4(final_color, alpha);
}
