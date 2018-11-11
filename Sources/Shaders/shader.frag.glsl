#version 450

uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;
const uint on_state = 160;
const uint dying_state = 80;

void main() {
	uint state = uint(round(texture(tex, uv).r * 255.0));
	if (state < on_state) {
		if (state < dying_state) {
			FragColor = vec4(vec3(0.0), 1.0);
		}
		else {
			FragColor = vec4(0.4, 0.0, 0.0, 1.0);
		}
	}
	else {
		FragColor = vec4(uv.x * 0.7 + 0.3, uv.y * 0.7 + 0.3 ,(uv.y - uv.x) * (uv.x - uv.y) * 1.3 + 0.3, 1.0);
	}
}
