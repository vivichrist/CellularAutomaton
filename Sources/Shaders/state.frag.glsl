#version 450

uniform int gridLen;
uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;
const float one = 0.00390625;

void main() {
	float stepsize = 1.0 / float(gridLen);
	float current = texture(tex, uv).x;
	// gather surrounding state
	uint state = 0;
	state += texture(tex, uv - vec2(stepsize,  stepsize)).x > 0.0 ? 1 : 0; //-1,-1
	state += texture(tex, uv - vec2(0.0,       stepsize)).x > 0.0 ? 1 : 0; // 0,-1
	state += texture(tex, uv + vec2(stepsize, -stepsize)).x > 0.0 ? 1 : 0; // 1,-1
	state += texture(tex, uv + vec2(stepsize, 		0.0)).x > 0.0 ? 1 : 0; // 1, 0
	state += texture(tex, uv + vec2(stepsize,  stepsize)).x > 0.0 ? 1 : 0; // 1, 1
	state += texture(tex, uv + vec2(0.0,	   stepsize)).x > 0.0 ? 1 : 0; // 0, 1
	state += texture(tex, uv + vec2(-stepsize, stepsize)).x > 0.0 ? 1 : 0; //-1, 1
	state += texture(tex, uv - vec2(stepsize, 		0.0)).x > 0.0 ? 1 : 0; //-1, 0
	if (state == 2 && current < 0.5 * one)
	{
		FragColor = vec4(2.0 * one);
	}
	else if (current <= 1.5 * one)
	{
		FragColor = vec4(0.0);
	}
	else if (current <= 2.5 * one)
	{
		FragColor = vec4(one);
	}
	else
	{
		FragColor = vec4(current);
	}
}
