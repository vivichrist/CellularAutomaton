#version 450

uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;

void main() {
	float current = texture(tex, uv).x;
	FragColor = vec4(current);
}
