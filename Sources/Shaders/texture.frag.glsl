#version 450

uniform int gridsize;
uniform sampler2D tex;
in vec2 uv;
out vec4 FragColor;

void main() {
	float stepsize = 1.0 / float(gridsize);
	// previous state of this cell
	uint current = uint(round(texture(tex, uv).r * 255.0));
	// gather surrounding previous state
	uint state = 0;
	bool xl = uv.x + stepsize < 1.0,
		 xg = uv.x - stepsize > 0.0,
		 yl = uv.y + stepsize < 1.0,
		 yg = uv.y - stepsize > 0.0;
	state += (round(texture(tex, uv + vec2(-stepsize,-stepsize)).r * 255.0) >= 160 && xg && yg ) ? 1 : 0; //-1,-1
	state += (round(texture(tex, uv + vec2(0.0,      -stepsize)).r * 255.0) >= 160 && yg)		 ? 1 : 0; // 0,-1
	state += (round(texture(tex, uv + vec2(stepsize, -stepsize)).r * 255.0) >= 160 && xl && yg ) ? 1 : 0; // 1,-1
	state += (round(texture(tex, uv + vec2(stepsize, 	   0.0)).r * 255.0) >= 160 && xl)		 ? 1 : 0; // 1, 0
	state += (round(texture(tex, uv + vec2(stepsize,  stepsize)).r * 255.0) >= 160 && xl && yl ) ? 1 : 0; // 1, 1
	state += (round(texture(tex, uv + vec2(0.0,		  stepsize)).r * 255.0) >= 160 && yl)		 ? 1 : 0; // 0, 1
	state += (round(texture(tex, uv + vec2(-stepsize, stepsize)).r * 255.0) >= 160 && xg && yl ) ? 1 : 0; //-1, 1
	state += (round(texture(tex, uv + vec2(-stepsize,	   0.0)).r * 255.0) >= 160 && xg)		 ? 1 : 0; //-1, 0
	// the rules of the game.
	if (current < 160) // less than on state
	{
		if (current < 80 && state == 2) // less than dying state and surrounded by two on cells
		{ // off -> on | if surrounded by two others
			FragColor = vec4(vec3(160.0 / 255.0), 1.0);
		}
		else
		{ // dying -> off
			FragColor = vec4(vec3(0.0), 1.0);
		}
	}
	else
	{ // on -> dying
		FragColor = vec4(vec3(80.0 / 255.0), 1.0);
	}
}
