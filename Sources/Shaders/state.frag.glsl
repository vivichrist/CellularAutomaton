#version 450

uniform int gridLen;
uniform usampler2D tex;
in vec2 uv;
out uint FragColor;

void main() {
	float stepsize = 1.0 / float(gridLen);
	uint current = texture(tex, uv).x;
	// gather surrounding state
	uint state = 0;
	state += texture(tex, uv - vec2(stepsize,  stepsize)).x > 0 ? 1 : 0; //-1,-1
	state += texture(tex, uv - vec2(0.0,       stepsize)).x > 0 ? 1 : 0; // 0,-1
	state += texture(tex, uv + vec2(stepsize, -stepsize)).x > 0 ? 1 : 0; // 1,-1
	state += texture(tex, uv + vec2(stepsize, 		0.0)).x > 0 ? 1 : 0; // 1, 0
	state += texture(tex, uv + vec2(stepsize,  stepsize)).x > 0 ? 1 : 0; // 1, 1
	state += texture(tex, uv + vec2(0.0,	   stepsize)).x > 0 ? 1 : 0; // 0, 1
	state += texture(tex, uv + vec2(-stepsize, stepsize)).x > 0 ? 1 : 0; //-1, 1
	state += texture(tex, uv - vec2(stepsize, 		0.0)).x > 0 ? 1 : 0; //-1, 0
	if (current == 2)
	{
		FragColor = 1;
	}
	else if (current == 1)
	{
		FragColor = 0;
	}
	else if (state == 2 && current == 0)
	{
		FragColor = 2;
	}
	else
	{
		FragColor = current;
	}
}
