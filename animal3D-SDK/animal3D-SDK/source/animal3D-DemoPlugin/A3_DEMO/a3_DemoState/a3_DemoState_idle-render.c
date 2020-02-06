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
	
	a3_DemoState_idle-render.c/.cpp
	Demo state function implementations.

	****************************************************
	*** THIS IS ONE OF YOUR DEMO'S MAIN SOURCE FILES ***
	*** Implement your demo logic pertaining to      ***
	***     RENDERING THE STATS in this file.        ***
	****************************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoRenderUtils.h"


// OpenGL
#ifdef _WIN32
#include <gl/glew.h>
#include <Windows.h>
#include <GL/GL.h>
#else	// !_WIN32
#include <OpenGL/gl3.h>
#endif	// _WIN32


//-----------------------------------------------------------------------------
// RENDER TEXT

void a3shading_render_controls(a3_DemoState const* demoState, a3_Demo_Shading const* demoMode,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset);
void a3pipelines_render_controls(a3_DemoState const* demoState, a3_Demo_Pipelines const* demoMode,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset);


// display current mode controls
void a3demo_render_controls(a3_DemoState const* demoState,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset)
{
	// display mode info
	a3byte const* modeText[demoState_mode_max] = {
		"LIGHTING & SHADING",
		"LIGHTING PIPELINES",
	};

	// text color
	a3vec4 const col = { a3real_half, a3real_zero, a3real_half, a3real_one };

	// demo mode
	a3_DemoState_ModeName const demoMode = demoState->demoMode;

	// demo mode
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Demo mode (%u / %u) ('</,' prev | next '>/.'): %s", demoMode + 1, demoState_mode_max, modeText[demoMode]);

	// draw controls for specific modes
	switch (demoMode)
	{
	case demoState_shading:
		a3shading_render_controls(demoState, demoState->demoMode_shading, textAlign, textDepth, textOffsetDelta, textOffset);
		break;
	case demoState_pipelines:
		a3pipelines_render_controls(demoState, demoState->demoMode_pipelines, textAlign, textDepth, textOffsetDelta, textOffset);
		break;
	}

	// global controls
	textOffset = -0.8f;
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Toggle text display:        't' (toggle) | 'T' (alloc/dealloc) ");
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Reload all shader programs: 'P' ****CHECK CONSOLE FOR ERRORS!**** ");
}


// display general controls
void a3demo_render_controls_gen(a3_DemoState const* demoState,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset)
{
	// boolean text
	a3byte const boolText[2][4] = {
		"OFF",
		"ON ",
	};

	// text color
	a3vec4 const col = { a3real_half, a3real_zero, a3real_half, a3real_one };

	// toggles
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"GRID (toggle 'g') %s | SKYBOX ('b') %s | HIDDEN VOLUMES ('h') %s", boolText[demoState->displayGrid], boolText[demoState->displaySkybox], boolText[demoState->displayHiddenVolumes]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"WORLD AXES (toggle 'x') %s | OBJECT AXES ('z') %s | TANGENT BASES ('B') %s", boolText[demoState->displayWorldAxes], boolText[demoState->displayObjectAxes], boolText[demoState->displayTangentBases]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"ANIMATION (toggle 'm') %s", boolText[demoState->updateAnimation]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"STENCIL (toggle 'i') %s", boolText[demoState->stencilTest]);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"    Forward point light count ('l' decr | incr 'L'): %u / %u", demoState->forwardLightCount, demoStateMaxCount_lightObject);

	// global controls
	textOffset = -0.8f;
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Toggle text display:        't' (toggle) | 'T' (alloc/dealloc) ");
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Reload all shader programs: 'P' ****CHECK CONSOLE FOR ERRORS!**** ");

	// input-dependent controls
	textOffset = -0.6f;
	if (a3XboxControlIsConnected(demoState->xcontrol))
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"Xbox controller camera control: ");
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    Left joystick = rotate | Right joystick, triggers = move");
	}
	else
	{
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"Keyboard/mouse camera control: ");
		a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
			"    Left click & drag = rotate | WASDEQ = move | wheel = zoom");
	}
}


// scene data (HUD)
void a3demo_render_data(const a3_DemoState* demoState,
	a3f32 const textAlign, a3f32 const textDepth, a3f32 const textOffsetDelta, a3f32 textOffset)
{
	// text color
	const a3vec4 col = { a3real_half, a3real_zero, a3real_half, a3real_one };

	// display some general data
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"t_render = %+.4lf ", demoState->renderTimer->totalTime);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"dt_render = %.4lf ", demoState->renderTimer->previousTick);
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"fps_actual = %.4lf ", __a3recipF64(demoState->renderTimer->previousTick));
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"fps_target = %.4lf ", (a3f64)demoState->renderTimer->ticks / demoState->renderTimer->totalTime);

	// global controls
	textOffset = -0.8f;
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Toggle text display:        't' (toggle) | 'T' (alloc/dealloc) ");
	a3textDraw(demoState->text, textAlign, textOffset += textOffsetDelta, textDepth, col.r, col.g, col.b, col.a,
		"Reload all shader programs: 'P' ****CHECK CONSOLE FOR ERRORS!**** ");
}


	// framebuffers
	const a3_Framebuffer* currentReadFBO, * currentWriteFBO;

	// indices
	a3ui32 i, j, k;

	// RGB
	const a3vec4 rgba4[] = {
		{ 1.0f, 0.0f, 0.0f, 1.0f },	// red
		{ 0.0f, 1.0f, 0.0f, 1.0f },	// green
		{ 0.0f, 0.0f, 1.0f, 1.0f },	// blue
		{ 0.0f, 1.0f, 1.0f, 1.0f },	// cyan
		{ 1.0f, 0.0f, 1.0f, 1.0f },	// magenta
		{ 1.0f, 1.0f, 0.0f, 1.0f },	// yellow
		{ 1.0f, 0.5f, 0.0f, 1.0f },	// orange
		{ 0.0f, 0.5f, 1.0f, 1.0f },	// sky blue
		{ 0.5f, 0.5f, 0.5f, 1.0f },	// solid grey
		{ 0.5f, 0.5f, 0.5f, 0.5f },	// translucent grey
	};
	const a3real
		*const red = rgba4[0].v, *const green = rgba4[1].v, *const blue = rgba4[2].v,
		*const cyan = rgba4[3].v, *const magenta = rgba4[4].v, *const yellow = rgba4[5].v,
		*const orange = rgba4[6].v, *const skyblue = rgba4[7].v,
		*const grey = rgba4[8].v, *const grey_t = rgba4[9].v;


	// bias matrix
	const a3mat4 bias = {
		0.5f, 0.0f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.5f, 0.0f,
		0.5f, 0.5f, 0.5f, 1.0f,
	};

	// final model matrix and full matrix stack
	a3mat4 modelViewProjectionMat = a3mat4_identity;
	a3mat4 modelViewMat = a3mat4_identity, modelMat = a3mat4_identity;

	// camera used for drawing
	const a3_DemoProjector *activeCamera = demoState->projector + demoState->activeCamera;
	const a3_DemoSceneObject *activeCameraObject = activeCamera->sceneObject;

	// current scene object being rendered, for convenience
	const a3_DemoSceneObject *currentSceneObject, *endSceneObject;

	// temp drawable pointers
	const a3_VertexDrawable* drawable[] = {
		demoState->draw_plane,
		demoState->draw_sphere,
		demoState->draw_cylinder,
		demoState->draw_torus,
		demoState->draw_teapot,
	};

	// temp texture pointers
	const a3_Texture* texture_dm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_dm,
		demoState->tex_stone_dm,
		demoState->tex_mars_dm,
		demoState->tex_checker,
	};
	const a3_Texture* texture_sm[] = {
		demoState->tex_stone_dm,
		demoState->tex_earth_sm,
		demoState->tex_stone_dm,
		demoState->tex_mars_sm,
		demoState->tex_checker,
	};

	// forward pipeline shader programs
	const a3_DemoStateShaderProgram* forwardProgram[][demoStateForwardShadingModeMax] = {
		{
			demoState->prog_drawColorUnif,
			demoState->prog_drawTexture,
			demoState->prog_drawLambert_multi,
			demoState->prog_drawPhong_multi,
			demoState->prog_drawNonphoto_multi,
		}, {
			demoState->prog_drawColorUnif,
			demoState->prog_drawTexture_mrt,
			demoState->prog_drawLambert_multi_mrt,
			demoState->prog_drawPhong_multi_mrt,
			demoState->prog_drawNonphoto_multi_mrt,
		},
	};

	// display shader programs
	const a3_DemoStateShaderProgram* displayProgram[][demoStateForwardDisplayModeMax] = {
		{
			0,
		}, {
			demoState->prog_drawTexture,
			demoState->prog_drawTexture_colorManip,
			demoState->prog_drawTexture_coordManip,
		},
	};

	// ****TO-DO: 
	//	-> 2.1g: framebuffer for display
	
	// framebuffers from which to read based on pipeline mode
	const a3_Framebuffer* readFBO[] = {
		0,
		demoState->fbo_scene,
	};
	

	// tmp lighting data
	a3f32 lightSz[demoStateMaxCount_lightObject];
	a3f32 lightSzInvSq[demoStateMaxCount_lightObject];
	a3vec4 lightPos[demoStateMaxCount_lightObject];
	a3vec4 lightCol[demoStateMaxCount_lightObject];


	//-------------------------------------------------------------------------
	// 1) SCENE PASS: render scene with desired shader
	//	- activate scene framebuffer
	//	- draw scene
	//		- clear buffers
	//		- render shapes using appropriate shaders
	//		- capture color and depth

	// select target framebuffer
	switch (demoSubMode)
	{
		// shading
	case demoStateSubMode_main_shading:
		// target back buffer (default)
		a3framebufferDeactivateSetViewport(a3fbo_depth24_stencil8,
			-demoState->frameBorder, -demoState->frameBorder, demoState->frameWidth, demoState->frameHeight);

		// skybox or regular clear
		glDisable(GL_STENCIL_TEST);
		glDisable(GL_BLEND);
		if (demoState->displaySkybox)
		{
			// change depth mode to 'always' to ensure box gets drawn and resets depth
			glDepthFunc(GL_ALWAYS);
			a3demo_drawSkybox(demoState);
			glDepthFunc(GL_LEQUAL);
		}
		else
		{
			// clearing is expensive!
			// only call clear if skybox is not used; 
			//	skybox will draw over everything otherwise
			glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		}
		break;

		// shading with MRT
	case demoStateSubMode_main_mrt:
		// ****TO-DO: 
		//	-> 2.1h: activate framebuffer
		
		// target scene framebuffer
		currentWriteFBO = demoState->fbo_scene;
		a3framebufferActivate(currentWriteFBO);
		

		// clear now, handle skybox later
		glDisable(GL_STENCIL_TEST);
		glDisable(GL_BLEND);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		break;
	}


	// optional stencil test before drawing objects
	if (demoState->stencilTest)
	{
		// draw to stencil buffer: 
		//	- render first sphere to the stencil buffer to set drawable area
		//		- don't want values for the shape to actually be drawn to 
		//			color or depth buffers, so apply a MASK for this object
		//	- enable stencil test for everything else

		// drawing "lens" object using simple program
		currentDemoProgram = demoState->prog_transform;
		a3shaderProgramActivate(currentDemoProgram->program);
		a3real4x4SetScale(modelMat.m, a3real_four);
		a3real4x4Product(modelViewProjectionMat.m, activeCamera->viewProjectionMat.m, modelMat.m);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);

		// default stencil write settings
		a3demo_enableStencilWrite();

		// enable test and clear buffer (do this after mask is set)
		glEnable(GL_STENCIL_TEST);
		glClear(GL_STENCIL_BUFFER_BIT);

		// disable drawing this object to color or depth
	//	glColorMask(...);
	//	glDepthMask(...);

		// inverted small sphere in solid transparent color
		// used as our "lens" for the depth and stencil tests
		glCullFace(GL_FRONT);
		a3vertexDrawableActivateAndRender(demoState->draw_sphere);
		glCullFace(GL_BACK);

		// enable drawing following objects to color and depth
	//	glColorMask(...);
	//	glDepthMask(...);

		// default stencil compare settings
		a3demo_enableStencilCompare();
	}


	// copy temp light data
	for (k = 0, pointLight = demoState->forwardPointLight;
		k < demoState->forwardLightCount;
		++k, ++pointLight)
	{
		lightSz[k] = pointLight->radius;
		lightSzInvSq[k] = pointLight->radiusInvSq;
		lightPos[k] = pointLight->viewPos;
		lightCol[k] = pointLight->color;
	}


	// support multiple geometry passes
	for (i = 0, j = 1; i < j; ++i)
	{
		// select forward algorithm
		switch (i)
		{
			// forward pass
		case 0: {
			// select program based on settings
			currentDemoProgram = forwardProgram[demoSubMode][demoState->forwardShadingMode];
			a3shaderProgramActivate(currentDemoProgram->program);

			// send shared data: 
			//	- projection matrix
			//	- light data
			//	- activate shared textures including atlases if using
			//	- shared animation data
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP, 1, activeCamera->projectionMat.mm);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uP_inv, 1, activeCamera->projectionMatInv.mm);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uAtlas, 1, a3mat4_identity.mm);
			a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, skyblue);
			a3shaderUniformSendInt(a3unif_single, currentDemoProgram->uLightCt, 1, &demoState->forwardLightCount);
			a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSz, demoState->forwardLightCount, lightSz);
			a3shaderUniformSendFloat(a3unif_single, currentDemoProgram->uLightSzInvSq, demoState->forwardLightCount, lightSzInvSq);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightPos, demoState->forwardLightCount, lightPos->v);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uLightCol, demoState->forwardLightCount, lightCol->v);
			a3textureActivate(demoState->tex_ramp_dm, a3tex_unit04);
			a3textureActivate(demoState->tex_ramp_sm, a3tex_unit05);

			// individual object requirements: 
			//	- modelviewprojection
			//	- modelview
			//	- modelview for normals
			//	- per-object animation data
			for (k = 0,
				currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
				currentSceneObject <= endSceneObject;
				++k, ++currentSceneObject)
			{
				// update and send data
				modelMat = currentSceneObject->modelMat;
				a3real4x4Product(modelViewMat.m, activeCameraObject->modelMatInv.m, modelMat.m);
				a3real4x4Product(modelViewProjectionMat.m, activeCamera->viewProjectionMat.m, modelMat.m);

				a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, rgba4[k + 3].v);
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV, 1, modelViewMat.mm);
				a3demo_quickInvertTranspose_internal(modelViewMat.m);
				modelViewMat.v3 = a3vec4_zero;
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMV_nrm, 1, modelViewMat.mm);
				a3textureActivate(texture_dm[k], a3tex_unit00);
				a3textureActivate(texture_sm[k], a3tex_unit01);

				// draw
				currentDrawable = drawable[k];
				a3vertexDrawableActivateAndRender(currentDrawable);
			}
		}	break;
			// end geometry pass
		}
	}


	// stop using stencil
	if (demoState->stencilTest)
		glDisable(GL_STENCIL_TEST);


	// draw grid aligned to world
	if (demoState->displayGrid)
	{
		currentDemoProgram = demoState->prog_drawColorUnif;
		a3shaderProgramActivate(currentDemoProgram->program);
		currentDrawable = demoState->draw_grid;
		modelViewProjectionMat = activeCamera->viewProjectionMat;
		a3real4x4ConcatL(modelViewProjectionMat.m, demoState->gridTransform.m);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, demoState->gridColor.v);
		a3vertexDrawableActivateAndRender(currentDrawable);
	}


	//-------------------------------------------------------------------------
	// PREPARE FOR POST-PROCESSING
	//	- double buffer swap (if applicable)
	//	- ensure blending is disabled
	//	- re-activate FSQ drawable IF NEEDED (i.e. changed in previous step)
	glDisable(GL_BLEND);
	currentDrawable = demoState->draw_unitquad;
	a3vertexDrawableActivate(currentDrawable);


	//-------------------------------------------------------------------------
	// DISPLAY: final pass, perform and present final composite
	//	- finally draw to back buffer
	//	- select display texture(s)
	//	- activate final pass program
	//	- draw final FSQ

	// revert to back buffer and disable depth testing
	a3framebufferDeactivateSetViewport(a3fbo_depthDisable,
		-demoState->frameBorder, -demoState->frameBorder, demoState->frameWidth, demoState->frameHeight);

	// ****TO-DO: 
	//	-> 2.3a: select display framebuffer
	
	// select framebuffer to display based on mode
	currentReadFBO = readFBO[demoSubMode];

	// select output to display
	switch (demoSubMode)
	{
		// no framebuffer active for scene render
	case demoStateSubMode_main_shading:
		// do nothing
		break;

		// scene was rendered to framebuffer
	case demoStateSubMode_main_mrt:
		// composite skybox
		if (demoState->displaySkybox)
		{
			a3demo_drawSkybox(demoState);
			a3demo_enableCompositeBlending();
		}

		// select output to display
		if (currentReadFBO->color && (!currentReadFBO->depthStencil || demoOutput < demoOutputCount - 1))
			a3framebufferBindColorTexture(currentReadFBO, a3tex_unit00, demoOutput);
		else
			a3framebufferBindDepthTexture(currentReadFBO, a3tex_unit00);
		break;
	}
	


	// ****TO-DO: 
	//	-> 2.3b: display scene rendered off-screen
	
	// final display: activate desired final program and draw FSQ
	if (currentReadFBO)
	{
		// prepare for final draw
		currentDrawable = demoState->draw_unitquad;
		a3vertexDrawableActivate(currentDrawable);

		// determine if additional passes are required
		{
			// most basic option: simply display texture
			currentDemoProgram = displayProgram[demoSubMode][demoState->forwardDisplayMode];
			a3shaderProgramActivate(currentDemoProgram->program);
		}

		// done
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, a3mat4_identity.mm);
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uAtlas, 1, a3mat4_identity.mm);
		a3shaderUniformSendDouble(a3unif_single, currentDemoProgram->uTime, 1, &demoState->renderTimer->totalTime);
		a3vertexDrawableRenderActive();
	}
	


	//-------------------------------------------------------------------------
	// OVERLAYS: done after FSQ so they appear over everything else
	//	- disable depth testing
	//	- draw overlays appropriately

	// hidden volumes
	if (demoState->displayHiddenVolumes)
	{
		// draw light volumes
		glCullFace(GL_FRONT);
		currentDemoProgram = demoState->prog_drawColorUnif;
		currentDrawable = demoState->draw_pointlight;
		a3shaderProgramActivate(currentDemoProgram->program);
		a3vertexDrawableActivate(currentDrawable);
		for (k = 0; k < demoState->forwardLightCount; ++k)
		{
			a3real4x4SetScale(modelMat.m, (a3real)0.005 * demoState->forwardPointLight[k].radius);
			modelMat.v3 = demoState->forwardPointLight[k].worldPos;
			a3real4x4Product(modelViewProjectionMat.m, activeCamera->viewProjectionMat.m, modelMat.m);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
			a3shaderUniformSendFloat(a3unif_vec4, currentDemoProgram->uColor, 1, demoState->forwardPointLight[k].color.v);
			a3vertexDrawableRenderActive();
		}
		glCullFace(GL_BACK);
	}


	// superimpose axes
	// draw coordinate axes in front of everything
	currentDemoProgram = demoState->prog_drawColorAttrib;
	a3shaderProgramActivate(currentDemoProgram->program);
	currentDrawable = demoState->draw_axes;
	a3vertexDrawableActivate(currentDrawable);

	// center of world from current viewer
	// also draw other viewer/viewer-like object in scene
	if (demoState->displayWorldAxes)
	{
		modelViewProjectionMat = activeCamera->viewProjectionMat;
		a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
		a3vertexDrawableRenderActive();
	}

	// individual objects
	if (demoState->displayObjectAxes)
	{
		// scene objects
		for (k = 0,
			currentSceneObject = demoState->planeObject, endSceneObject = demoState->teapotObject;
			currentSceneObject <= endSceneObject;
			++k, ++currentSceneObject)
		{
			a3real4x4Product(modelViewProjectionMat.m, activeCamera->viewProjectionMat.m, currentSceneObject->modelMat.m);
			a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
			a3vertexDrawableRenderActive();
		}

		// other objects
		if (demoState->displayHiddenVolumes)
		{
			for (k = 0,
				currentSceneObject = demoState->mainLightObject, endSceneObject = demoState->mainLightObject;
				currentSceneObject <= endSceneObject;
				++k, ++currentSceneObject)
			{
				a3real4x4Product(modelViewProjectionMat.m, activeCamera->viewProjectionMat.m, currentSceneObject->modelMat.m);
				a3shaderUniformSendFloatMat(a3unif_mat4, 0, currentDemoProgram->uMVP, 1, modelViewProjectionMat.mm);
				a3vertexDrawableRenderActive();
			}
		}
	}


	// pipeline
	if (demoState->displayPipeline)
	{

	}

	// ****TO-DO: optionally comment out
	currentReadFBO = currentWriteFBO = 0;
}


//-----------------------------------------------------------------------------
// RENDER

void a3shading_render(a3_DemoState const* demoState, a3_Demo_Shading const* demoMode);
void a3pipelines_render(a3_DemoState const* demoState, a3_Demo_Pipelines const* demoMode);

void a3demo_render(a3_DemoState const* demoState)
{
	// display mode for current pipeline
	// ensures we don't go through the whole pipeline if not needed
	a3_DemoState_ModeName const demoMode = demoState->demoMode;


	// amount to offset text as each line is rendered
	a3f32 const textAlign = -0.98f;
	a3f32 const textDepth = -1.00f;
	a3f32 const textOffsetDelta = -0.08f;
	a3f32 textOffset = +1.00f;


	// choose render sub-routine for the current mode
	switch (demoMode)
	{
	case demoState_shading:
		a3shading_render(demoState, demoState->demoMode_shading);
		break;
	case demoState_pipelines:
		a3pipelines_render(demoState, demoState->demoMode_pipelines);
		break;
	}


	// deactivate things
	a3vertexDrawableDeactivate();
	a3shaderProgramDeactivate();
	a3framebufferDeactivateSetViewport(a3fbo_depthDisable, 0, 0, demoState->windowWidth, demoState->windowHeight);
	a3textureDeactivate(a3tex_unit00);


	// text
	if (demoState->textInit)
	{
		// choose text render mode
		switch (demoState->textMode)
		{
			// controls for current mode
		case demoState_textControls:
			a3demo_render_controls(demoState, textAlign, textDepth, textOffsetDelta, textOffset);
			break;

			// controls for general
		case demoState_textControls_gen:
			a3demo_render_controls_gen(demoState, textAlign, textDepth, textOffsetDelta, textOffset);
			break;

			// general data
		case demoState_textData:
			a3demo_render_data(demoState, textAlign, textDepth, textOffsetDelta, textOffset);
			break;
		}
	}
}


//-----------------------------------------------------------------------------
