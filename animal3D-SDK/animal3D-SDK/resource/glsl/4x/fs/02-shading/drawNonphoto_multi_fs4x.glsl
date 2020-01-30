/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawNonphoto_multi_fs4x.glsl
	Draw nonphotorealistic shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement nonphotorealistic shading model
//	Note: test all data and inbound values before using them!

uniform sampler2D uImage0;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform int uLightCt;

in vec4 vTexCoord;
in vec4 vViewPos;
in vec4 vNorm;

out vec4 rtFragColor;

float rampDiff(float r)
{
    float minL = 0.05;
    float cutoff  = 0.5;
    float stripes = 3.0;
    
    float v = step(cutoff, r);
    
    if(v==1.0)
		return ceil((r-cutoff) / (1.0-cutoff) * stripes) / stripes;
    else
        return v+minL;
}

vec4 findLight(vec4 lPos, vec4 lCol)
{
	// get normalized light direction
	vec4 lDir = normalize(lPos - vViewPos);

	// get the dot product w a min of 0
	float res = max(dot(vNorm, lDir), 0.0);

	// Return the dot product with light considered
	return rampDiff(res) * lCol;
}

void main()
{
	// accum var for dot prods
	vec4 accum = vec4(0.0);

	// iterate over light array
	for(int i = 0; i < uLightCt; i++)
	{
		// accumulate light and color
		accum += findLight(uLightPos[i], uLightCol[i]);
	}

	// sample the texture
	vec4 texSample = texture2D(uImage0, vTexCoord.xy);

	rtFragColor = accum * texSample;

	// DUMMY OUTPUT: all fragments are OPAQUE BLUE
	// rtFragColor = vec4(0.0, 0.0, 1.0, 1.0);
}
