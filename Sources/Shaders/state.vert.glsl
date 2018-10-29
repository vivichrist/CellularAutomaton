#version 450

in vec3 pos;
out vec2 uv;

void main() {
	gl_Position = vec4(pos.xyz, 1.0);
	uv = (pos.xy + vec2(1.0, 1.0)) / vec2(2.0, 2.0);
}
