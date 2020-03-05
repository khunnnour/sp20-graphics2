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
	
	drawCurveSegment_gs4x.glsl
	Draw curve segment based on waypoints being passed from application.
*/

#version 430

// (16 samples/segment * 1 segment + 4 samples/handle * 2 handles)
#define MAX_VERTICES 24

#define MAX_WAYPOINTS 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> model-view-projection matrix (no inbound position at all)
//		-> flag to select curve type
//		-> optional: segment index and count
//		-> optional: curve color (can hard-code)
//		-> optional: other animation data
//	4) declare output layout specifications
//	5) declare outbound color
//	6) write interpolation functions to help with sampling
//	7) select curve type and sample over [0, 1] interval

uniform int uFlag;
uniform int uIndex;
uniform int uCount;
uniform double uTime;
uniform vec4 uColor;
uniform mat4 uMVP;

in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} inVertexData[];

layout (line_strip, max_vertices=MAX_VERTICES) out;

out vec4 vColor;

vec4 lerp(vec4 A, vec4 B, float t)
{
	return mix(A, B, t);
}

vec4 quadBez(vec4 A, vec4 B, vec4 C, float t)
{
	vec4 D = mix(A, B, t); // D = A + t(B - A)
	vec4 E = mix(B, C, t); // E = B + t(C - B)
	
	vec4 P = mix(D, E, t); // P = D + t(E - D)
	
	return P;
}



void main()
{
	
}
