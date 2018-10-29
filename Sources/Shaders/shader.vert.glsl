#version 450

uniform int gridLen;
uniform usampler2D tex;
in vec3 pos;
in vec2 trans;
out vec3 vCol;
const float third = 1.0 / 3.0;
const float twotrd = 2.0 / 3.0;
const float hueScale = 4.5;

void main() {
	float hue = (gl_InstanceID == 0) ? 0.0 : float(gl_InstanceID) / float(gridLen * gridLen);
	float hs = 1.0 / (2.0 * gridLen); // halfstep
	float gx = float(mod(gl_InstanceID, gridLen)) / float(gridLen) + hs;
	float gy = floor(float(gl_InstanceID) / float(gridLen)) / float(gridLen) + hs;
	uint state = texture(tex, vec2(gx, gy)).x;
	if (hue < third)
	{
		float h = hue * hueScale;
		vCol = vec3(cos(h), sin(h), 0.0);
	}
	else if (hue < twotrd)
	{
		float h = (hue - third) * hueScale;
		vCol = vec3(0.0, cos(h), sin(h));
	}
	else
	{
		float h = (hue - twotrd) * hueScale;
		vCol = vec3(sin(h), 0.0, cos(h));
	}
	// state atributes
	if (state > 1)
	{
		gl_Position = vec4(pos.x + trans.x, pos.y + trans.y, pos.z, 1.0);
	}
	else if (state > 0)
	{
	 	vCol = vec3(0.4, 0.0, 0.0);
	}
	else 
	{ // don't render
		gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
	}
}
