shader_type canvas_item;

uniform float strength : hint_range(0, 200);
uniform float speed : hint_range(0, 10);
uniform float edge0 : hint_range(0, 1);
uniform float edge1 : hint_range(0, 1);

void vertex() {
	float time = TIME * speed;

	//float ratio = 1.0 - (VERTEX.y) / 150.0;
	float ratio = 1.0 - UV.y;

	ratio = clamp(ratio, 0.0, 1.0);
	
	float mask = smoothstep(edge0, edge1, ratio);
	
	// Debug
	//COLOR = vec4(1.0);

	VERTEX.x += cos(time) * mask * strength;
}