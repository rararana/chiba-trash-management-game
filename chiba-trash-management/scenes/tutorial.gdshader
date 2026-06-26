shader_type canvas_item;

uniform vec2 screen_size = vec2(1920.0, 1080.0);
uniform vec2 center = vec2(960.0, 540.0);
uniform float radius = 0.0;
uniform vec2 aspect = vec2(1.0, 1.0); 
uniform vec4 bg_color = vec4(0.0, 0.0, 0.0, 0.45);

void fragment() {
	vec2 pixel_pos = UV * screen_size;
	vec2 offset = (pixel_pos - center) / aspect;
	float dist = length(offset);
	float alpha = smoothstep(radius, radius + 5.0, dist);
	COLOR = vec4(bg_color.rgb, bg_color.a * alpha);
}