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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) implement outline algorithm - see render code for uniform hints

// uniform texture variable
uniform sampler2D screenTexture;
uniform sampler2D uImage0;
uniform sampler2D uImage1;

// inbound varying for texture coordinate
in vec4 vTexCoord;

out vec4 rtFragColor;

void main()
{
	/* - START SOBEL - */
	// Holds values
	vec4 colorVals[9];

	// == sample all pixels in 3x3 == //
	float w = 1.0 / textureSize(uImage1, 0).x;
	float h = 1.0 / textureSize(uImage1, 0).y;

	// bottom row
	colorVals[0] = texture2D(uImage1, vec2(vTexCoord.x-w,vTexCoord.y-h));
	colorVals[1] = texture2D(uImage1, vec2(vTexCoord.x+0,vTexCoord.y-h));
	colorVals[2] = texture2D(uImage1, vec2(vTexCoord.x+w,vTexCoord.y-h));
	// middle row
	colorVals[3] = texture2D(uImage1, vec2(vTexCoord.x-w,vTexCoord.y+0));
	colorVals[4] = texture2D(uImage1, vec2(vTexCoord.x+0,vTexCoord.y+0));
	colorVals[5] = texture2D(uImage1, vec2(vTexCoord.x+w,vTexCoord.y+0));
	// top row
	colorVals[6] = texture2D(uImage1, vec2(vTexCoord.x-w,vTexCoord.y+h));
	colorVals[7] = texture2D(uImage1, vec2(vTexCoord.x+0,vTexCoord.y+h));
	colorVals[8] = texture2D(uImage1, vec2(vTexCoord.x+w,vTexCoord.y+h));

	// find gx and y values
	vec4 G, gX, gY;

	gX = (colorVals[2]+2*colorVals[5]+colorVals[8])-(colorVals[0]+2*colorVals[3]+colorVals[6]);
	gY = (colorVals[6]+2*colorVals[7]+colorVals[8])-(colorVals[0]+2*colorVals[1]+colorVals[2]);

	G = sqrt(gX*gX + gY*gY);
	/* - END SOBEL - */

	// sample the texture
	vec4 texSample = texture2D(screenTexture, vTexCoord.xy);
	
	float outWeight = 5.0;
	rtFragColor = vec4(1.0-G.rgb*outWeight,1.0)*texSample;
	//rtFragColor = texSample;
}
