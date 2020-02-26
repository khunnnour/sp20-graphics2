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
uniform sampler2D uImage06; //
uniform sampler2D uImage07;	//
uniform vec4 uColor;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;
uniform int uLightCt;

in vec4 vViewPosition;
in vec4 vViewNormal;
in vec4 vTexcoord;
//in vec4 vBiasedClipCoord;

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

float aExp = 64.0;
float ka = 0.01, kd = 1.0, ks = 1.0;

// Calculate specularity
vec4 findSpecular(vec4 lPos, vec4 lCol)
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);
	   
	// Calc position here
	float depth = texture(uImage00, vTexcoord.xy).x;
	vec4 pos = uPB_inv * vec4(vTexcoord.xy,depth,1.0);
	pos *= 1/pos.a;

	// get normalized view vector
	vec4 viewVec = -normalize(pos);

	// get normalized reflection vector
	vec4 refVec = normalize(lPos - viewVec);
	
	// get normal from map and uncompress
	vec4 normSamp = texture(uImage02, vTexcoord.xy);
	vec4 newNorm = (normSamp-0.5)*2.0;
	refVec = reflect(refVec, newNorm);
	
	// get the dot product w a min of 0
	float res = max(dot(viewVec, refVec), 0.0);
	res = pow(res, aExp);

	// Return the dot product
	return ks * res * lCol;
}

// Calculate diffuse lighting
vec4 findLight(vec4 lPos, vec4 lCol)
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);
	   
	// Calc position here
	float depth = texture(uImage00, vTexcoord.xy).x;
	vec4 pos = uPB_inv * vec4(vTexcoord.xy,depth,1.0);
	pos *= 1/pos.a;

	// get normalized light vector
	vec4 lDir = normalize(lPos - pos);

	// get normal from map and uncompress
	vec4 normSamp = texture(uImage02, vTexcoord.xy);
	vec4 newNorm = (normSamp-0.5)*2.0;

	float res = max(dot(newNorm, lDir), 0.0);

	// Return the dot product with light and size considered
	return kd * res * lCol;
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
	
	rtDiffuseLightTotal  = vec4(diffuseAccum.xyz, 1.0);
	rtSpecularLightTotal = vec4(specularAccum.xyz,1.0);
	
	// add up phong
	phong = findAmbient() + diffuseAccum * rtDiffuseMapSample + specularAccum * rtSpecularMapSample;
	
	return phong;
}

void main()
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);

	// Sample Maps
	vec4 diffSamp = texture(uImage04, actCoord.xy);
	rtDiffuseMapSample = vec4(diffSamp.xyz,1.0);

	vec4 specSamp = texture(uImage05, actCoord.xy);
	rtSpecularMapSample = vec4(specSamp.xyz,1.0);

	// get phong
	vec4 accum = findPhong();

	//rtDiffuseMapSample   = vec4(1.0,0.0,0.0,1.0);
	//rtSpecularMapSample  = vec4(1.0,0.0,1.0,1.0);
	//rtDiffuseLightTotal  = vec4(0.0,1.0,1.0,1.0);
	//rtSpecularLightTotal = vec4(0.0,1.0,0.0,1.0);
	
	// output new color
	rtFragColor = vec4(accum.xyz,1.0);
	//rtFragColor = vec4(,1.0);
}
