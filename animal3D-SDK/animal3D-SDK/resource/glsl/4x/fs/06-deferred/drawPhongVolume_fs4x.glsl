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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

struct data
{
	vec4 worldPos;		// position in world space
	vec4 viewPos;		// position in viewer space
	vec4 color;			// RGB color with padding
	float radius;		// radius (distance of effect from center)
	float radiusInvSq;	// radius inverse squared (attenuation factor)
	float pad[2];		// padding
};

uniform ubPointLight 
{
	data lightContent[4];
} lightData;

uniform mat4 uPB_inv;
uniform sampler2D uImage00; //depth
uniform sampler2D uImage01; //position
uniform sampler2D uImage02; //normal
uniform sampler2D uImage03; //texcoord
uniform sampler2D uImage04; //diffuse
uniform sampler2D uImage05;	//specular
uniform vec4 uColor;
uniform vec4[4] uLightPos;
uniform vec4[4] uLightCol;
uniform float[4] uLightSz;
uniform int uLightCt;

in vec4 vViewPosition;
in vec4 vViewNormal;
in vec4 vTexcoord;
in vec4 vBiasedClipCoord;
flat in int vInstanceID;

layout (location = 0) out vec4 rtFragColor;
layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

float aExp = 64.0;
float ka = 0.01, kd = 1.0, ks = 1.0;
vec4 viewNormal,viewPos;

// Calculate specularity
vec4 findSpecular(vec4 lPos, vec4 lCol)
{
	// get normalized view vector
	vec4 viewVec = -normalize(viewPos);

	// get normalized reflection vector
	vec4 refVec = normalize(lPos - viewPos);
	//refVec = reflect(refVec, viewNormal);

	// get the dot product w a min of 0
	float res = max(dot(viewVec, refVec), 0.0);
	res = pow(res, aExp);

	// Return the dot product
	return ks * res * lCol;
}

// Calculate diffuse lighting
vec4 findLight(vec4 lPos, vec4 lCol)
{
	// get normalized light vector
	vec4 lDir = normalize(lPos - viewPos);
		
	float res = max(dot(viewNormal, lDir), 0.0);

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
	// Find view normal
	vec4 newNorm = texture(uImage02, vTexcoord.xy);
	//newNorm = uPB_inv * newNorm;
	viewNormal = normalize((newNorm-0.5)*2.0);

	// Find view position
	float depth = texture(uImage00, vTexcoord.xy).x;
	viewPos = uPB_inv * vec4(vTexcoord.xy,depth,1.0);
	viewPos *= 1/viewPos.a;

	vec4 phong, specularAccum, diffuseAccum;
	vec4 amb;

	// additive blending diffuse
	diffuseAccum += findLight(lightData.lightContent[vInstanceID].worldPos, lightData.lightContent[vInstanceID].color);
	
	// additive blending specularity
	specularAccum += findSpecular(lightData.lightContent[vInstanceID].worldPos, lightData.lightContent[vInstanceID].color);
		
	rtDiffuseLight  = diffuseAccum;
	rtSpecularLight = specularAccum;
	
	// add up phong
	phong = findAmbient() + diffuseAccum + specularAccum;
	
	return phong;
}

void main()
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);

	// get phong
	vec4 accum = findPhong();

	// output new color
	rtFragColor = vec4(accum.xyz,1.0);
	//rtFragColor = vec4(,1.0);
}
