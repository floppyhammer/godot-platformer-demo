shader_type canvas_item;

uniform sampler2D gradient_texture;
uniform float strength : hint_range(0, 0.1);
uniform float distort_scale : hint_range(0, 10);
uniform float speed : hint_range(0, 10);

float rand(vec2 coord) {
	return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 coord) {
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

void fragment() {
	float gradient = texture(gradient_texture, UV).a;
	
	vec2 noisecoord1 = UV * distort_scale;
	vec2 noisecoord2 = UV * distort_scale + 5.0;
	
	vec2 motion1 = vec2(TIME * speed * 0.3, TIME * speed * -0.4);
	vec2 motion2 = vec2(TIME * speed * 0.1, TIME * speed * 0.5);
	
	vec2 distort1 = vec2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1)) - vec2(0.5);
	vec2 distort2 = vec2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2)) - vec2(0.5);
	
	vec2 distor_sum = (distort1 + distort2) * strength;
	
	// Distort UV
	vec2 uv = UV;
	uv += distor_sum;
	
	vec4 color = texture(TEXTURE, uv);
	
	COLOR = color;
}