shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

uniform float grain_amount : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float average = (color.r + color.g + color.b) / 3.0;

    // Add random noise to the average color value
    float noise = random(vec2(UV)) * 2.0 - 1.0;
    average += noise * grain_amount;

    COLOR = vec4(vec3(average), color.a);
}