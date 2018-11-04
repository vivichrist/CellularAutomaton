#version 450

in vec3 pos;
out vec2 uv;

void main() {
	gl_Position = vec4(pos.x, pos.y, 0.5, 1.0);
	uv = vec2((pos.x + 1.0) / 2.0, (pos.y + 1.0) / 2.0);
}
