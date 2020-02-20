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
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare additional texture uniforms
//	2) implement screen function with 4 inputs
//	3) use screen function to sample input textures

uniform sampler2D uImage00;
uniform sampler2D uImage01;
uniform sampler2D uImage02;
uniform sampler2D uImage03;

in vec4 vTexCoord;
out vec4 rtFragColor;

vec4 screen(sampler2D,sampler2D,sampler2D,sampler2D);

void main()
{
	rtFragColor = screen(uImage00, uImage01, uImage02, uImage03);
}

vec4 screen(sampler2D A, sampler2D B, sampler2D C, sampler2D D)
{
	// sample diff buffers
	vec4 colA = texture2D(A, vTexCoord.xy);
	vec4 colB = texture2D(B, vTexCoord.xy);
	vec4 colC = texture2D(C, vTexCoord.xy);
	vec4 colD = texture2D(D, vTexCoord.xy);

	// screen function
	vec4 color = 1.0-(1.0-colA)*(1.0-colB)*(1.0-colC)*(1.0-colD);

	return color;
}