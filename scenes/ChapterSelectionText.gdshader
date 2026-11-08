
shader_type canvas_item;

uniform float blur_strength : hint_range(0.0, 3.0) = 1.5;
uniform float fade_amount : hint_range(0.0, 1.0) = 0.35;

void fragment() {
    vec2 p = TEXTURE_PIXEL_SIZE * blur_strength;

    vec4 c = vec4(0.0);
    c += texture(TEXTURE, UV + p * vec2(-1.0, -1.0));
    c += texture(TEXTURE, UV + p * vec2( 0.0, -1.0)) * 2.0;
    c += texture(TEXTURE, UV + p * vec2( 1.0, -1.0));
    c += texture(TEXTURE, UV + p * vec2(-1.0,  0.0)) * 2.0;
    c += texture(TEXTURE, UV) * 4.0;
    c += texture(TEXTURE, UV + p * vec2( 1.0,  0.0)) * 2.0;
    c += texture(TEXTURE, UV + p * vec2(-1.0,  1.0));
    c += texture(TEXTURE, UV + p * vec2( 0.0,  1.0)) * 2.0;
    c += texture(TEXTURE, UV + p * vec2( 1.0,  1.0));
    c /= 16.0;

    float gray = dot(c.rgb, vec3(0.299, 0.587, 0.114));
    vec3 faded = mix(vec3(gray), vec3(0.55), fade_amount);

    COLOR = vec4(faded, c.a);
}