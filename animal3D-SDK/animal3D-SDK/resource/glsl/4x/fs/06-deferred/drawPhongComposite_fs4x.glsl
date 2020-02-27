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
	
	drawPhongComposite_fs4x.glsl
	Draw final Phong shading model by compositing lighting with textures.
*/

#version 410

// ****TO-DO: 
//	1) declare texture coordinate g-buffer to get surface UVs
//	2) declare diffuse and specular maps as uniform samplers
//	3) declare diffuse and specular light textures as uniform samplers
//	4) declare ambient color as uniform vector
//	5) calculate Phong shading model by sampling from light buffers and 
//		multiplying by the respective surface texture sample and summing 
//		the components: 
//			PHONG =	ambient light 
//					+ diffuse light * diffuse sample 
//					+ specular light * specular sample 

uniform sampler2D uImage00; //
uniform sampler2D uImage01; //diffuse textures
uniform sampler2D uImage02; //specular textures
uniform sampler2D uImage03; //texcoord
uniform sampler2D uImage04; //diffuse map
uniform sampler2D uImage05; //specular map

uniform vec4 uColor;

in vec4 vTexcoord;

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;

vec4 getPhong()
{
	// get correct coord
	vec4 actCoord = texture(uImage03, vTexcoord.xy);
	
	// sample maps
	rtDiffuseMapSample  = texture(uImage04,actCoord.xy);
	rtSpecularMapSample = texture(uImage05,actCoord.xy);
	
	// sample textures
	vec4 diffTexSample = texture(uImage01,vTexcoord.xy);
	vec4 specTexSample = texture(uImage02,vTexcoord.xy);

	// composite
	vec4 phong = 0.01*uColor + diffTexSample*rtDiffuseMapSample + specTexSample*rtSpecularMapSample;

	return phong;
}

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE YELLOW (and others)
	rtFragColor = vec4(getPhong().rgb,1.0);
	rtFragColor.a = rtDiffuseMapSample.a;

	//rtDiffuseMapSample = vec4(1.0, 0.0, 0.0, 1.0);
	//rtSpecularMapSample = vec4(0.0, 1.0, 0.0, 1.0);
}
