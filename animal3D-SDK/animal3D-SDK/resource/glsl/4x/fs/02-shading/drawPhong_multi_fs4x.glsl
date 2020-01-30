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
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!


uniform sampler2D uImage0;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;
uniform int uLightCt;

in vec4 vTexCoord;
in vec4 vViewPos;
in vec4 vNorm;

out vec4 rtFragColor;

float aExp = 64.0;
float ka = 0.1, kd = 0.6, ks = 1.5;

// Calculate specularity
float findSpecular(vec4 lPos, vec4 lCol)
{
	// get normalized view vector
	vec4 viewVec = normalize(vViewPos);

	// get normalized reflection vector
	vec4 refVec = normalize(lPos - vViewPos);
	refVec = reflect(refVec, normalize(vNorm));

	// get the dot product w a min of 0
	float res = max(dot(viewVec, refVec), 0.0);
	res = pow(res, aExp);

	// Return the dot product
	return ks * res;
}

// Calculate diffuse lighting
float findLight(vec4 lPos, vec4 lCol)
{
	// get normalized light direction
	vec4 lDir = normalize(lPos - vViewPos);

	// get the dot product w a min of 0
	float res = max(dot(vNorm, lDir), 0.0);

	// Return the dot product with light and size considered
	return kd * res;
}

// Calculate ambient lighting
vec4 findAmbient(vec4 col)
{
	return ka * col;
}

// Calculate phong
vec4 findPhong()
{
	vec4 phong;
	vec4 amb;

	// iterate over light array
	for(int i = 0; i < uLightCt; i++)
	{
		float summedCoef=0.0;
		// add diffuse
		//phong += findLight(uLightPos[i], uLightCol[i]);
		summedCoef+= findLight(uLightPos[i], uLightCol[i]);
		
		// add specularity
		//phong += findSpecular(uLightPos[i], uLightCol[i]);
		summedCoef+=findSpecular(uLightPos[i], uLightCol[i]);
		
		phong += summedCoef * uLightCol[i];
	}

	// add ambient
	phong += findAmbient(texture2D(uImage0, vTexCoord.xy));
	
	return phong;
}

void main()
{
	// get phong
	vec4 accum = findPhong();

	// sample the texture
	vec4 texSample = texture2D(uImage0, vTexCoord.xy);

	// output new color
	rtFragColor = texSample * accum;
	//rtFragColor = vTexCoord;
}
