shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float strength : hint_range(0.0, 0.1) = 0.03;
uniform float frequency : hint_range(0.0, 20.0) = 8.0;
uniform float border_softness : hint_range(0.0, 0.5) = 0.1;
uniform float progress : hint_range(0.0, 1.0) = 1.0;
uniform float end_curve : hint_range(0.0, 1.0) = 0.2;
uniform vec4 flash_color = vec4(1.0, 0.0, 0.0, 0.0);

void fragment() {
    vec2 uv = UV;


    if (uv.x > progress) {
        discard;
    }

    float fade_width = max(end_curve, 0.1);
    float fade_start = max(0.0, progress - fade_width);
    
    if (progress > 0.0 && uv.x > 0.01) {
        float t = (uv.x - fade_start) / max(fade_width, 0.0001);
        
        float distance_from_center = abs(uv.y - 0.75) * 2.0;
        float curve_factor = 1.0 - pow(t, 2.0);
        
        if (distance_from_center > curve_factor) {
            discard;
        }
    }

    if (uv.y < 0.5) {
        uv.y += sin(uv.x * frequency + TIME * speed) * strength;
    }
    vec4 tex_color = texture(TEXTURE, uv);
    COLOR = mix(tex_color * COLOR, flash_color, flash_color.a);
}
