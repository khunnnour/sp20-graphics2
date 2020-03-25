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
	
	drawNonphoto_multi_fs4x.glsl
	Draw nonphotorealistic shading model for multiple lights.
*/

#version 410

/* *
 * Code originally by Erik Nordeus for Unity 
 *  -> https://www.habrador.com/tutorials/shaders/2-interior-mapping/
 * Modifed for a3/openGL by Conner and Cormac
 * */

in vec4 vTexCoord;
in vec4 vViewPos;
in vec4 vNorm;

out vec4 rtFragColor;

// Floor dimensions
const float roomHeight = 0.25;
const float roomWidth  = 0.25;
// Colors
const vec3 wallCol  = vec3(0.9, 0.3, 0.2);
const vec3 wallCol2 = vec3(0.9, 1.0, 0.9);
const vec3 roofCol  = vec3(0.2, 0.6, 0.9);
const vec3 floorCol = vec3(0.4, 0.2, 0.1);

// Prototypes
vec4 checkDistance(vec3 rayDir, vec3 rayStartPos, vec3 planePos, vec3 planeNormal, vec3 color, vec4 colorAndDist);
vec3 map(vec4 viewDir, vec4 vPos);

void main()
{
	// Calcluate the direction to vertex
	vec4 viewDirection = vTexCoord-vViewPos;

	// Actual mapping function
	vec3 col = map(viewDirection, vTexCoord);

	rtFragColor = vec4(col, 1.0);
	// DUMMY OUTPUT; SHOULD MAKE THINGS MAGENTA OR SOMETHING
	//rtFragColor = vec4(1.0,0.,0.0,1.0);
}

vec3 map(vec4 viewDir, vec4 vPos) 
{
	// Direction vectors
	vec3 upVec = vec3(0, 1, 0);
	vec3 rightVec = vec3(1, 0, 0);
	vec3 forwardVec = vec3(0, 0, 1);

	// The view direction of the camera to this fragment in local space
	vec3 rayDir = normalize(viewDir).xyz;

	// The local position of this fragment
	vec3 rayStartPos = vPos.xyz;

	// Important to start inside the house or we will display one of the outer walls
	rayStartPos += rayDir * 0.0001;

	// Init the loop with a vec4 to make it easier to return from a function
	// colorAndDist.rgb is the color that will be displayed
	// colorAndDist.w is the shortest distance to a wall so far so we can find which wall is the closest
	vec4 colorAndDist = vec4(vec3(1,1,1), 100000000.0);

	// Intersection 1: Wall / roof (y)
	// Camera is looking up if the dot product is > 0 = Roof
	if (dot(upVec, rayDir) > 0)
	{				
		//The local position of the roof
		vec3 wallPos = (ceil(rayStartPos.y / roomHeight) * roomHeight) * upVec;

		//Check if the roof is intersecting with the ray, if so set the color and the distance to the roof and return it
		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, upVec, roofCol, colorAndDist);
	}
	// Floor
	else
	{
		vec3 wallPos = ((ceil(rayStartPos.y / roomHeight) - 1.0) * roomHeight) * upVec;

		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, upVec * -1, floorCol, colorAndDist);
	}
	

	// Intersection 2: Right wall (x)
	if (dot(rightVec, rayDir) > 0)
	{
		vec3 wallPos = (ceil(rayStartPos.x / roomWidth) * roomWidth) * rightVec;

		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, rightVec, wallCol, colorAndDist);
	}
	else
	{
		vec3 wallPos = ((ceil(rayStartPos.x / roomWidth) - 1.0) * roomWidth) * rightVec;

		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, rightVec * -1, wallCol, colorAndDist);
	}


	// Intersection 3: Forward wall (z)
	if (dot(forwardVec, rayDir) > 0)
	{
		vec3 wallPos = (ceil(rayStartPos.z / roomWidth) * roomWidth) * forwardVec;

		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, forwardVec, wallCol2, colorAndDist);
	}
	else
	{
		vec3 wallPos = ((ceil(rayStartPos.z / roomWidth) - 1.0) * roomWidth) * forwardVec;

		colorAndDist = checkDistance(rayDir, rayStartPos, wallPos, forwardVec * -1, wallCol2, colorAndDist);
	}
		
	// Output
	return colorAndDist.rgb;
}

// Calculate the distance between the ray start position and where it's intersecting with the plane
// If this distance is shorter than the previous best distance, the save it and the color belonging to the wall and return it
vec4 checkDistance(vec3 rayDir, vec3 rayStartPos, vec3 planePos, vec3 planeNormal, vec3 color, vec4 colorAndDist)
{
	// Get the distance to the plane with ray-plane intersection
	// http://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-plane-and-ray-disk-intersection
	// We are always intersecting with the plane so we dont need to spend time checking that			
	float t = dot(planePos - rayStartPos, planeNormal) / dot(planeNormal, rayDir);

	// If the distance is closer to the camera than the previous best distance
	if (t < colorAndDist.w)
	{
		// This distance is now the best distance
		colorAndDist.w = t;

		// Set the color that belongs to this wall
		colorAndDist.rgb = color;
	}

	return colorAndDist;
}