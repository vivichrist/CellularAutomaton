#version 450

uniform int gridsize;
uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;
const float dying_state = 0.3125; // 80 * 1/256
const float on_state = 0.625; // 160 * 1/256
const float epsilon = 0.005;

void main() {
	float stepsize = 1.0 / float(gridsize + 1);
	// previous state of this cell
	float current = texture(tex, uv).r;
	// gather surrounding previous state
	uint state = 0;
	bool xl = uv.x + stepsize < 1.0, xg = uv.x - stepsize > 0.0, yl = uv.y + stepsize < 1.0, yg = uv.y - stepsize > 0.0;
	state += (texture(tex, uv + vec2(-stepsize,-stepsize)).x >= (dying_state + epsilon) && xg && yg ) ? 1 : 0; //-1,-1
	state += (texture(tex, uv + vec2(0.0,      -stepsize)).x >= (dying_state + epsilon) && yg)		? 1 : 0; // 0,-1
	state += (texture(tex, uv + vec2(stepsize, -stepsize)).x >= (dying_state + epsilon) && xl && yg ) ? 1 : 0; // 1,-1
	state += (texture(tex, uv + vec2(stepsize, 		 0.0)).x >= (dying_state + epsilon) && xl)		? 1 : 0; // 1, 0
	state += (texture(tex, uv + vec2(stepsize,  stepsize)).x >= (dying_state + epsilon) && xl && yl ) ? 1 : 0; // 1, 1
	state += (texture(tex, uv + vec2(0.0,	    stepsize)).x >= (dying_state + epsilon) && yl)		? 1 : 0; // 0, 1
	state += (texture(tex, uv + vec2(-stepsize, stepsize)).x >= (dying_state + epsilon) && xg && yl ) ? 1 : 0; //-1, 1
	state += (texture(tex, uv + vec2(-stepsize, 	 0.0)).x >= (dying_state + epsilon) && xg)		? 1 : 0; //-1, 0

	if (current < (on_state - epsilon))
	{
		if (current < (dying_state - epsilon))
		{ // off -> on | if surrounded by two others
			FragColor = (state == 2) ? vec4(vec3(on_state), 1.0) : vec4(vec3(0.0), 1.0);
		}
		else
		{ // dying -> off
			FragColor = vec4(vec3(0.0), 1.0);
		}
	}
	else
	{ // on -> dying
		FragColor = vec4(vec3(dying_state), 1.0);
	}
}
