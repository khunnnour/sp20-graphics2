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
	
	a3_DemoShaderProgram.h
	Wrapper for shaders used in demo state.
*/

#ifndef __ANIMAL3D_DEMOSHADERPROGRAM_H
#define __ANIMAL3D_DEMOSHADERPROGRAM_H


//-----------------------------------------------------------------------------
// animal3D framework includes

#include "animal3D-A3DG/a3graphics/a3_ShaderProgram.h"


//-----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C"
{
#else	// !__cplusplus
	typedef struct a3_DemoStateShader			a3_DemoStateShader;
	typedef struct a3_DemoStateShaderProgram	a3_DemoStateShaderProgram;
#endif	// __cplusplus


//-----------------------------------------------------------------------------

	// maximum number of uniforms in a program
	enum a3_DemoShaderProgramMaxCounts
	{
		demoStateMaxCount_shaderProgramUniform = 32,
		demoStateMaxCount_shaderProgramUniformBlock = 2,
	};


	// structure to help with shader management
	struct a3_DemoStateShader
	{
		a3_Shader shader[1];
		a3byte shaderName[32];

		a3_ShaderType shaderType;
		a3ui32 srcCount;
		const a3byte *filePath[8];	// max number of source files per shader
	};


	// structure to help with shader program and uniform management
	struct a3_DemoStateShaderProgram
	{
		a3_ShaderProgram program[1];

		// single uniforms
		union {
			a3i32 uniformLocation[demoStateMaxCount_shaderProgramUniform];
			struct {
				a3i32
					// common vertex shader uniform handles
					uMVP,						// model-view-projection transform (object -> clip)
					uMV,						// model-view matrix (object -> view)
					uP,							// projection matrix (view -> clip)
					uP_inv,						// projection matrix inverse (clip -> view)
					uMV_nrm,					// model-view matrix for normals (object -> view)
					uAtlas;						// atlas matrix for texture coordinates
					
				a3i32
					// common fragment shader uniform handles
					uLightCt,					// light count
					uLightSz,					// light size
					uLightSzInvSq,				// light size inverse squared
					uLightPos,					// light position (in whatever space makes sense)
					uLightCol,					// light color
					uColor;						// uniform color (used in whatever context is needed)

				a3i32
					// common texture handles
					uTex_dm, uTex_sm,
					uTex_dm_ramp, uTex_sm_ramp,
					uImage0;

				a3i32
					// common general uniform handles
					uTime;						// time
			};
		};

		// uniform blocks
		union {
			a3i32 uniformBlockLocation[demoStateMaxCount_shaderProgramUniformBlock];
			struct {
				a3i32
					// transformation uniform block handles
					ubTransformMVP;		// model-view-projection matrix block

				a3i32
					// lighting uniform block handles
					ubPointLight;		// point light structure block
			};
		};
	};


//-----------------------------------------------------------------------------


#ifdef __cplusplus
}
#endif	// __cplusplus


#endif	// !__ANIMAL3D_DEMOSHADERPROGRAM_H