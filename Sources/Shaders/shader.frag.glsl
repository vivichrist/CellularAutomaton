#version 450

uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;

void main() {
	uint col = uint(round(texture(tex, uv).r * 255.0));
	if (col < 160) {
		if (col < 80) {
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
