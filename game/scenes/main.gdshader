shader_type canvas_item;

uniform float radius;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	vec2 local_cords = (UV - center);
	float distance = length(local_cords);
	float circle_radius = radius / float(2);
	if(distance > circle_radius) {
		discard;
	}
}