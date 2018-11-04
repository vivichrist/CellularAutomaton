#version 450

uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;

void main() {
	float col = texture(tex, uv).r;
	FragColor = vec4(col);
}
