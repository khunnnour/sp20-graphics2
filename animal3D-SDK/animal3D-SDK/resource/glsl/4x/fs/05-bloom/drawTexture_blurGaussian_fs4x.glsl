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
	
	drawTexture_blurGaussian_fs4x.glsl
	Draw texture with Gaussian blurring.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare uniforms for pixel size and sampling axis
//	2) implement Gaussian blur function using a 1D kernel (hint: Pascal's triangle)
//	3) sample texture using Gaussian blur function and output result

uniform sampler2D uImage00;
uniform vec2 uSize;
uniform vec2 uAxis;

in vec4 vTexCoord;
out vec4 rtFragColor;

vec4 getGaussed()
{
	float[5] blurKern = float[5]( 0.0625, 0.25, 0.375, 0.25, 0.0625 );
    
    // Holds values
	vec4 colorVals[5];
	
    // pixel w/h
	float w = 1.0 / textureSize(uImage00, 0).x;
	float h = 1.0 / textureSize(uImage00, 0).y;
    
	colorVals[0] = texture(uImage00, vTexCoord.xy+2.0*vec2(w,h)*uAxis)*blurKern[0];
	colorVals[1] = texture(uImage00, vTexCoord.xy+1.0*vec2(w,h)*uAxis)*blurKern[1];
	colorVals[2] = texture(uImage00, vTexCoord.xy+0.0*vec2(w,h)*uAxis)*blurKern[2];
	colorVals[3] = texture(uImage00, vTexCoord.xy-1.0*vec2(w,h)*uAxis)*blurKern[3];
	colorVals[4] = texture(uImage00, vTexCoord.xy-2.0*vec2(w,h)*uAxis)*blurKern[4];
    
    vec4 col = colorVals[0] + colorVals[1] + colorVals[2] + colorVals[3] + colorVals[4];

	return vec4(col.xyz,1.0);
}

void main()
{
	rtFragColor = getGaussed();

	//rtFragColor = texSample;
}
