shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.62, 0.20, 1.0);

uniform float glow_strength = 0.90;
uniform float pulse_speed = 3.0;

void fragment() {
    // Distance from the center
    vec2 uv = UV - vec2(0.5);
    float dist = length(uv);

    // Animated pulse: 0 to 1
    float pulse = 0.5 + 0.5 * sin(TIME * pulse_speed);

    // Make the entire circular glow expand and contract
    float radius = mix(0.27, 0.47, pulse);

    // Soft outer glow
    float outer = 1.0 - smoothstep(
        radius * 0.65,
        radius + 0.12,
        dist
    );

    // Stronger inner glow
    float inner = 1.0 - smoothstep(
        radius * 0.20,
        radius * 0.75,
        dist
    );

    // Combine both layers
    float glow = outer * 0.55 + inner * 0.45;

    // Brightness changes with the radius
    float brightness = mix(0.45, 1.0, pulse);

    COLOR.rgb = glow_color.rgb;
    COLOR.a = glow * glow_strength * brightness;
}