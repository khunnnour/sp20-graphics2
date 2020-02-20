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
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader
//	1) receive shadow coordinate
//	2) perform perspective divide
//	3) declare shadow map texture
//	4) perform shadow test

uniform sampler2D uImage0;
uniform sampler2D uTex_shadow;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;
uniform int uLightCt;

layout (location = 1) out vec4 mrtViewPos;
layout (location = 2) out vec4 mrtViewNorm;
layout (location = 3) out vec4 mrtTexCoord;
layout (location = 4) out vec4 mrtDiffTex;
layout (location = 5) out vec4 mrtSpecTex;
layout (location = 6) out vec4 mrtDiffLight;
layout (location = 7) out vec4 mrtSpecLight;

in vec4 passedShadCoord;
in vec4 vTexCoord;
in vec4 vViewPos;
in vec4 vNorm;

out vec4 rtFragColor;

float aExp = 64.0;
float ka = 0.1, kd = 0.6, ks = 1.5;

float totSpec = 0.0;
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
	totSpec += res;

	// Return the dot product
	return ks * res;
}

float totDiff=0.0; // for mrt diffuse map
// Calculate diffuse lighting
float findLight(vec4 lPos, vec4 lCol)
{
	// get normalized light direction
	vec4 lDir = normalize(lPos - vViewPos);

	// get the dot product w a min of 0
	float res = max(dot(vNorm, lDir), 0.0);
	totDiff += res;

	// Return the dot product with light and size considered
	return kd * res;
}

// Calculate ambient lighting
vec4 findAmbient(vec4 col)
{
	return ka * col;
}

vec4 diffAccum;
vec4 specAccum;
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
		summedCoef += findLight(uLightPos[i], uLightCol[i]);
		diffAccum += findLight(uLightPos[i], uLightCol[i]) * uLightCol[i];

		// add specularity
		summedCoef += findSpecular(uLightPos[i], uLightCol[i]);
		specAccum += findSpecular(uLightPos[i], uLightCol[i]) * uLightCol[i];

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

	// perspective divide
	vec4 projCoord = passedShadCoord / passedShadCoord.w;

	float shadowSample = texture2D(uTex_shadow, projCoord.xy).r;

	float isShadow = step(projCoord.z, shadowSample);

	// Output to Render Targets
	mrtViewPos   = vec4(vViewPos.xyz, 1.0);
	mrtViewNorm  = vec4(vNorm.xyz, 1.0);
	mrtTexCoord  = vec4(vTexCoord.xyz, 1.0);
	mrtDiffTex	 = vec4((totDiff*texSample).xyz, 1.0);
	mrtSpecTex	 = vec4((totSpec*texSample).xyz, 1.0);
	mrtDiffLight = vec4(diffAccum.xyz, 1.0);
	mrtSpecLight = vec4(specAccum.xyz, 1.0);

	// output new color
	rtFragColor = vec4((isShadow * texSample * accum).xyz,1.0);
	//rtFragColor = vTexCoord;
}
