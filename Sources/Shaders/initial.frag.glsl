#version 450

uniform usampler2D tex;
in vec2 uv;
out uint FragColor;

void main() {
	uint current = texture(tex, uv).x;
	FragColor = current;
}
