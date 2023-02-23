shader_type canvas_item;

uniform vec2 direction = vec2(1, 1);
uniform float speed = 0.2;

void fragment() {
	COLOR = texture(TEXTURE, vec2(UV.x, UV.y) + TIME * direction * speed);
}
