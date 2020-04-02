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
	
	passColor_hierarchy_transform_instanced_vs4x.glsl
	Transform position attribute for instance and pass color based on 
		instance in a hierarchy.
*/

#version 410

#define MAX_INSTANCES 1024
#define MAX_NODES 128
#define MAX_COLORS 12

// ****TO-DO: 
//	1) declare structure to store single hierarchy node data
//		(hint: look in the framework)
//		(hint: char is not a thing here, but 1 int = 4 chars)
//	2) declare uniform block to read list of hierarchy nodes
//	3) select color from array based on some component of the 
//		current hierarchy node being drawn
//		(e.g. level in hierarchy from root node)
//	4) copy selected color to outbound color

layout (location = 0) in vec4 aPosition;

uniform ubTransformMVP {
	mat4 uMVP[MAX_INSTANCES];
};

struct a3_HierarchyNode
{	// 1 int = 4 bytes
	int name[8];
	int index;
	int parentIndex;
};

uniform ubHierarchy {
	a3_HierarchyNode node[MAX_NODES];
};

uniform vec4 uColor[MAX_COLORS];

out vec4 vColor;

void main()
{
	gl_Position = uMVP[gl_InstanceID] * aPosition;

	int colorIndex = node[gl_InstanceID].index;

	// DUMMY OUTPUT: select first color
	vColor = uColor[colorIndex];
}
