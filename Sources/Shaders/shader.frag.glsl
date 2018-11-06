#version 450

uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;
const float dying_state = 0.3125;
const float on_state = 0.625;
const float epsilon = 0.005;

void main() {
	float col = texture(tex, uv).r;
	if (col < dying_state - (dying_state - on_state) * 0.5) {
		if (col < (dying_state - epsilon)) {
			FragColor = vec4(vec3(0.0), 1.0);
		}
		else {
			FragColor = vec4(0.25, 0.0, 0.0, 1.0);
		}
	}
	else {
		FragColor = vec4(uv.x * 0.7 + 0.3, uv.y * 0.7 + 0.3 ,(uv.y - uv.x) * (uv.x - uv.y) * 1.3 + 0.3, 1.0);
	}
}
