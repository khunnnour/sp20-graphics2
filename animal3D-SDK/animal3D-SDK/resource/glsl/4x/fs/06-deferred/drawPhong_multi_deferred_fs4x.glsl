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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

uniform mat4 uPB_inv;
uniform sampler2D uImage00;
uniform sampler2D uImage01; //position
uniform sampler2D uImage02; //normal
uniform sampler2D uImage03; //texcoord
uniform sampler2D uImage04; //diffuse map
uniform sampler2D uImage05;	//specular map
uniform vec4 uColor;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;
uniform int uLightCt;

in vbLightingData {
	vec4 vViewPosition;
	vec4 vViewNormal;
	vec4 vTexcoord;
	vec4 vBiasedClipCoord;
};

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

float aExp = 64.0;
float ka = 1.0, kd = 1.0, ks = 1.0;

// Calculate specularity
vec4 findSpecular(vec4 lPos, vec4 lCol)
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);
	   
	// get normalized view vector
	vec4 viewVec = normalize(vViewPosition);

	// get normalized reflection vector
	vec4 refVec = normalize(lPos - vViewPosition);
	
	// get normal from map and uncompress
	vec4 normSamp = texture(uImage02, actCoord.xy);
	vec4 newNorm = (normSamp-0.5)*2.0;
	refVec = reflect(refVec, newNorm);
	
	// get the dot product w a min of 0
	float res = max(dot(viewVec, refVec), 0.0);
	res = pow(res, aExp);

	// sample spec map
	vec4 specSamp = texture(uImage05, actCoord.xy);

	// Return the dot product
	return ks * res * lCol * specSamp;
}

// Calculate diffuse lighting
vec4 findLight(vec4 lPos, vec4 lCol)
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);
	
	// get normalized light direction
	vec4 lDir = normalize(lPos - vViewPosition);

	// get normal from map and uncompress
	vec4 normSamp = texture(uImage02, actCoord.xy);
	vec4 newNorm = (normSamp-0.5)*2.0;

	// get the dot product w a min of 0
	float res = max(dot(newNorm, lDir), 0.0);

	// sample diff map
	vec4 diffSamp = texture(uImage04, actCoord.xy);

	// Return the dot product with light and size considered
	return kd * res * lCol * diffSamp;
}

// Calculate ambient lighting
vec4 findAmbient()
{
	return ka * uColor;
}

// Calculate phong
vec4 findPhong()
{
	vec4 phong, specularAccum, diffuseAccum;
	vec4 amb;

	// iterate over light array
	for(int i = 0; i < uLightCt; i++)
	{
		// add diffuse
		diffuseAccum += findLight(uLightPos[i], uLightCol[i]);
		
		// add specularity
		specularAccum += findSpecular(uLightPos[i], uLightCol[i]);
	}
	
	// add up phong
	phong = findAmbient() + diffuseAccum + specularAccum;
	
	return phong;
}

void main()
{
	// get phong
	vec4 accum = findPhong();

	// output new color
	rtFragColor = accum;
	//rtFragColor = actTexCoord;
}
