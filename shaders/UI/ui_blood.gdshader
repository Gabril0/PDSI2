shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float strength : hint_range(0.0, 0.1) = 0.03;
uniform float frequency : hint_range(0.0, 20.0) = 8.0;
uniform float border_softness : hint_range(0.0, 0.5) = 0.1;
uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float end_curve : hint_range(0.0, 1.0) = 0.6;
uniform vec4 flash_color = vec4(1.0, 0.0, 0.0, 0.0);

void fragment() {
    vec2 uv = UV;

    if (uv.y < 0.5) {
        uv.y += sin(uv.x * frequency + TIME * speed) * strength;
    }

    if (uv.x > (end_curve * progress)) {
        float fade = smoothstep(1.0, end_curve * progress, uv.x);
        uv.y *= fade;
    }

    vec4 tex_color = texture(TEXTURE, uv);
    COLOR = mix(tex_color * COLOR, flash_color, flash_color.a);
}
