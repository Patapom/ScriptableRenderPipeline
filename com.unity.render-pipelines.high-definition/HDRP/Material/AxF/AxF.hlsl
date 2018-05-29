//-----------------------------------------------------------------------------
// SurfaceData and BSDFData
//-----------------------------------------------------------------------------
// SurfaceData is defined in AxF.cs which generates AxF.cs.hlsl
#include "AxF.cs.hlsl"
//#include "../SubsurfaceScattering/SubsurfaceScattering.hlsl"
//#include "CoreRP/ShaderLibrary/VolumeRendering.hlsl"

//NEWLITTODO : wireup CBUFFERs for ambientocclusion, and other uniforms and samplers used:
//
// We need this for AO, Depth/Color pyramids, LTC lights data, FGD pre-integrated data.
//
// Also add options at the top of this file, see Lit.hlsl.


// This function is use to help with debugging and must be implemented by any lit material
// Implementer must take into account what are the current override component and
// adjust SurfaceData properties accordingdly
void ApplyDebugToSurfaceData( float3x3 worldToTangent, inout SurfaceData surfaceData ) {
#ifdef DEBUG_DISPLAY
	// NOTE: THe _Debug* uniforms come from /HDRP/Debug/DebugDisplay.hlsl

	// Override value if requested by user
	// this can be use also in case of debug lighting mode like diffuse only
	bool overrideAlbedo = _DebugLightingAlbedo.x != 0.0;
	bool overrideSmoothness = _DebugLightingSmoothness.x != 0.0;
	bool overrideNormal = _DebugLightingNormal.x != 0.0;

	if ( overrideAlbedo ) {
		float3 overrideAlbedoValue = _DebugLightingAlbedo.yzw;
		surfaceData.diffuseColor = overrideAlbedoValue;
	}

	if ( overrideSmoothness ) {
		//NEWLITTODO
		//float overrideSmoothnessValue = _DebugLightingSmoothness.y;
		//surfaceData.perceptualSmoothness = overrideSmoothnessValue;
	}

	if ( overrideNormal ) {
		surfaceData.normalWS = worldToTangent[2];
	}
#endif
}

// This function is similar to ApplyDebugToSurfaceData but for BSDFData
//
// NOTE:
//
// This will be available and used in ShaderPassForward.hlsl since in AxF.shader,
// just before including the core code of the pass (ShaderPassForward.hlsl) we include
// Material.hlsl (or Lighting.hlsl which includes it) which in turn includes us,
// AxF.shader, via the #if defined(UNITY_MATERIAL_*) glue mechanism.
//
void ApplyDebugToBSDFData( inout BSDFData bsdfData ) {
#ifdef DEBUG_DISPLAY
	// Override value if requested by user
	// this can be use also in case of debug lighting mode like specular only

	//NEWLITTODO
	//bool overrideSpecularColor = _DebugLightingSpecularColor.x != 0.0;

	//if (overrideSpecularColor)
	//{
	//   float3 overrideSpecularColor = _DebugLightingSpecularColor.yzw;
	//    bsdfData.fresnel0 = overrideSpecularColor;
	//}
#endif
}

//-----------------------------------------------------------------------------
// conversion function for forward
//-----------------------------------------------------------------------------

BSDFData ConvertSurfaceDataToBSDFData( SurfaceData surfaceData ) {
	BSDFData bsdfData;
	ZERO_INITIALIZE(BSDFData, bsdfData);

	// NEWLITTODO: will be much more involved obviously, and use metallic, etc.
	bsdfData.diffuseColor = surfaceData.diffuseColor;
	bsdfData.normalWS = surfaceData.normalWS;

	ApplyDebugToBSDFData(bsdfData);
	return bsdfData;
}

//-----------------------------------------------------------------------------
// Debug method (use to display values)
//-----------------------------------------------------------------------------

void GetSurfaceDataDebug(uint paramId, SurfaceData surfaceData, inout float3 result, inout bool needLinearToSRGB)
{
	GetGeneratedSurfaceDataDebug(paramId, surfaceData, result, needLinearToSRGB);

	// Overide debug value output to be more readable
	switch ( paramId ) {
		case DEBUGVIEW_AXF_SURFACEDATA_NORMAL_VIEW_SPACE:
			// Convert to view space
			result = TransformWorldToViewDir(surfaceData.normalWS) * 0.5 + 0.5;
			break;
	}
}

void GetBSDFDataDebug(uint paramId, BSDFData bsdfData, inout float3 result, inout bool needLinearToSRGB)
{
	GetGeneratedBSDFDataDebug(paramId, bsdfData, result, needLinearToSRGB);

	// Overide debug value output to be more readable
	switch ( paramId ) {
		case DEBUGVIEW_AXF_BSDFDATA_NORMAL_VIEW_SPACE:
			// Convert to view space
			result = TransformWorldToViewDir(bsdfData.normalWS) * 0.5 + 0.5;
			break;
	}
}


//-----------------------------------------------------------------------------
// PreLightData
//
// Make sure we respect naming conventions to reuse ShaderPassForward as is,
// ie struct (even if opaque to the ShaderPassForward) name is PreLightData,
// GetPreLightData prototype.
//-----------------------------------------------------------------------------

// Precomputed lighting data to send to the various lighting functions
struct PreLightData {
	float NdotV;                     // Could be negative due to normal mapping, use ClampNdotV()
	//NEWLITTODO
};

PreLightData GetPreLightData( float3 V, PositionInputs posInput, inout BSDFData bsdfData ) {
	PreLightData preLightData;
	ZERO_INITIALIZE(PreLightData, preLightData);

	float3 N = bsdfData.normalWS;
	preLightData.NdotV = dot(N, V);

	//float NdotV = ClampNdotV(preLightData.NdotV);


	return preLightData;
}


//-----------------------------------------------------------------------------
// bake lighting function
//-----------------------------------------------------------------------------

//
// GetBakedDiffuseLighting will be called from ShaderPassForward.hlsl.
//
// GetBakedDiffuseLighting function compute the bake lighting + emissive color to be store in emissive buffer (Deferred case)
// In forward it must be add to the final contribution.
// This function require the 3 structure surfaceData, builtinData, bsdfData because it may require both the engine side data, and data that will not be store inside the gbuffer.
float3 GetBakedDiffuseLighting( SurfaceData surfaceData, BuiltinData builtinData, BSDFData bsdfData, PreLightData preLightData ) {
	//NEWLITTODO

#ifdef DEBUG_DISPLAY
	if (_DebugLightingMode == DEBUGLIGHTINGMODE_LUX_METER) {
		// The lighting in SH or lightmap is assume to contain bounced light only (i.e no direct lighting), and is divide by PI (i.e Lambert is apply), so multiply by PI here to get back the illuminance
		return builtinData.bakeDiffuseLighting * PI;
	}
#endif

	//NEWLITTODO
	// Premultiply bake diffuse lighting information with DisneyDiffuse pre-integration
	//return builtinData.bakeDiffuseLighting * preLightData.diffuseFGD * surfaceData.ambientOcclusion * bsdfData.diffuseColor + builtinData.emissiveColor;
	return builtinData.bakeDiffuseLighting * bsdfData.diffuseColor; //...todo, just to return something for now, .bakeDiffuseLighting is bogus for now anyway.
}


//-----------------------------------------------------------------------------
// light transport functions
//-----------------------------------------------------------------------------

LightTransportData	GetLightTransportData( SurfaceData surfaceData, BuiltinData builtinData, BSDFData bsdfData ) {
	LightTransportData lightTransportData;

	// diffuseColor for lightmapping should basically be diffuse color.
	// But rough metals (black diffuse) still scatter quite a lot of light around, so
	// we want to take some of that into account too.

	//NEWLITTODO
	//float roughness = PerceptualRoughnessToRoughness(bsdfData.perceptualRoughness);
	//lightTransportData.diffuseColor = bsdfData.diffuseColor + bsdfData.fresnel0 * roughness * 0.5 * surfaceData.metallic;
	lightTransportData.diffuseColor = bsdfData.diffuseColor;
	lightTransportData.emissiveColor = builtinData.emissiveColor;

	return lightTransportData;
}

//-----------------------------------------------------------------------------
// LightLoop related function (Only include if required)
// HAS_LIGHTLOOP is define in Lighting.hlsl
//-----------------------------------------------------------------------------

#ifdef HAS_LIGHTLOOP

#ifndef _SURFACE_TYPE_TRANSPARENT
// For /Lighting/LightEvaluation.hlsl:
#define USE_DEFERRED_DIRECTIONAL_SHADOWS // Deferred shadows are always enabled for opaque objects
#endif

#include "../../Lighting/LightEvaluation.hlsl"
#include "../../Lighting/Reflection/VolumeProjection.hlsl"

//-----------------------------------------------------------------------------
// Lighting structure for light accumulation
//-----------------------------------------------------------------------------

// These structure allow to accumulate lighting accross the Lit material
// AggregateLighting is init to zero and transfer to EvaluateBSDF, but the LightLoop can't access its content.
//
// In fact, all structures here are opaque but used by LightLoop.hlsl.
// The Accumulate* functions are also used by LightLoop to accumulate the contributions of lights.
//
struct DirectLighting {
	float3 diffuse;
	float3 specular;
};

struct IndirectLighting {
	float3 specularReflected;
	float3 specularTransmitted;
};

struct AggregateLighting {
	DirectLighting   direct;
	IndirectLighting indirect;
};

void AccumulateDirectLighting( DirectLighting src, inout AggregateLighting dst ) {
	dst.direct.diffuse += src.diffuse;
	dst.direct.specular += src.specular;
}

void AccumulateIndirectLighting( IndirectLighting src, inout AggregateLighting dst ) {
	dst.indirect.specularReflected += src.specularReflected;
	dst.indirect.specularTransmitted += src.specularTransmitted;
}

//-----------------------------------------------------------------------------
// BSDF share between directional light, punctual light and area light (reference)
//-----------------------------------------------------------------------------

// NEWLITTODO

// This function apply BSDF. Assumes that NdotL is positive.
void	BSDF( float3 V, float3 L, float NdotL, float3 positionWS, PreLightData preLightData, BSDFData bsdfData,
				out float3 diffuseLighting,
				out float3 specularLighting ) {

	float  diffuseTerm = Lambert();

	// We don't multiply by 'bsdfData.diffuseColor' here. It's done only once in PostEvaluateBSDF().
	diffuseLighting = diffuseTerm;
	specularLighting = float3(0.0, 0.0, 0.0);
}

//-----------------------------------------------------------------------------
// EvaluateBSDF_Directional
//-----------------------------------------------------------------------------

DirectLighting	EvaluateBSDF_Directional( LightLoopContext lightLoopContext,
											float3 V, PositionInputs posInput, PreLightData preLightData,
											DirectionalLightData lightData, BSDFData bsdfData,
											BakeLightingData bakeLightingData ) {

	DirectLighting lighting;
	ZERO_INITIALIZE(DirectLighting, lighting);

	float3 N     = bsdfData.normalWS;
	float3 L     = -lightData.forward; // Lights point backward in Unity
	//float  NdotV = ClampNdotV(preLightData.NdotV);
	float  NdotL = dot(N, L);
	//float  LdotV = dot(L, V);

	// color and attenuation are outputted  by EvaluateLight:
	float3 color;
	float attenuation;
	EvaluateLight_Directional( lightLoopContext, posInput, lightData, bakeLightingData, N, L, color, attenuation );

	float intensity = max(0, attenuation * NdotL); // Warning: attenuation can be greater than 1 due to the inverse square attenuation (when position is close to light)

	// Note: We use NdotL here to early out, but in case of clear coat this is not correct. But we are ok with this
	UNITY_BRANCH if (intensity > 0.0)
	{
		BSDF( V, L, NdotL, posInput.positionWS, preLightData, bsdfData, lighting.diffuse, lighting.specular );

		lighting.diffuse  *= intensity * lightData.diffuseScale;
		lighting.specular *= intensity * lightData.specularScale;
	}

	// NEWLITTODO: Mixed thickness, transmission

	// Save ALU by applying light and cookie colors only once.
	lighting.diffuse  *= color;
	lighting.specular *= color;

#ifdef DEBUG_DISPLAY
	if ( _DebugLightingMode == DEBUGLIGHTINGMODE_LUX_METER ) {
		lighting.diffuse = color * intensity * lightData.diffuseScale;	// Only lighting, not BSDF
	}
#endif

	return lighting;
}

//-----------------------------------------------------------------------------
// EvaluateBSDF_Punctual (supports spot, point and projector lights)
//-----------------------------------------------------------------------------

DirectLighting	EvaluateBSDF_Punctual( LightLoopContext lightLoopContext,
										float3 V, PositionInputs posInput,
										PreLightData preLightData, LightData lightData, BSDFData bsdfData, BakeLightingData bakeLightingData ) {
	DirectLighting	lighting;
	ZERO_INITIALIZE(DirectLighting, lighting);

	float3	lightToSample = posInput.positionWS - lightData.positionWS;
	int		lightType     = lightData.lightType;

	float3 L;
	float4 distances; // {d, d^2, 1/d, d_proj}
	distances.w = dot(lightToSample, lightData.forward);

	if ( lightType == GPULIGHTTYPE_PROJECTOR_BOX ) {
		L = -lightData.forward;
		distances.xyz = 1; // No distance or angle attenuation
	} else {
		float3 unL     = -lightToSample;
		float  distSq  = dot(unL, unL);
		float  distRcp = rsqrt(distSq);
		float  dist    = distSq * distRcp;

		L = unL * distRcp;
		distances.xyz = float3(dist, distSq, distRcp);
	}

	float3 N     = bsdfData.normalWS;
	float  NdotV = ClampNdotV(preLightData.NdotV);
	float  NdotL = dot(N, L);
	float  LdotV = dot(L, V);

	// NEWLITTODO: mixedThickness, transmission

	float3 color;
	float attenuation;
	EvaluateLight_Punctual(lightLoopContext, posInput, lightData, bakeLightingData, N, L,
							lightToSample, distances, color, attenuation);


	float intensity = max(0, attenuation * NdotL); // Warning: attenuation can be greater than 1 due to the inverse square attenuation (when position is close to light)

	// Note: We use NdotL here to early out, but in case of clear coat this is not correct. But we are ok with this
	UNITY_BRANCH if (intensity > 0.0)
	{
		// Simulate a sphere light with this hack
		// Note that it is not correct with our pre-computation of PartLambdaV (mean if we disable the optimization we will not have the
		// same result) but we don't care as it is a hack anyway

		//NEWLITTODO: Do we want this hack in stacklit ? Yes we have area lights, but cheap and not much maintenance to leave it here.
		// For now no roughness anyways.

		//bsdfData.coatRoughness = max(bsdfData.coatRoughness, lightData.minRoughness);
		//bsdfData.roughnessT = max(bsdfData.roughnessT, lightData.minRoughness);
		//bsdfData.roughnessB = max(bsdfData.roughnessB, lightData.minRoughness);

		BSDF(V, L, NdotL, posInput.positionWS, preLightData, bsdfData, lighting.diffuse, lighting.specular);

		lighting.diffuse  *= intensity * lightData.diffuseScale;
		lighting.specular *= intensity * lightData.specularScale;
	}

	//NEWLITTODO : transmission


	// Save ALU by applying light and cookie colors only once.
	lighting.diffuse  *= color;
	lighting.specular *= color;

#ifdef DEBUG_DISPLAY
	if ( _DebugLightingMode == DEBUGLIGHTINGMODE_LUX_METER ) {
		lighting.diffuse = color * intensity * lightData.diffuseScale;		// Only lighting, not BSDF
	}
#endif

	return lighting;
}

// NEWLITTODO: For a refence rendering option for area light, like LIT_DISPLAY_REFERENCE_AREA option in eg EvaluateBSDF_<area light type> :
//#include "LitReference.hlsl"

//-----------------------------------------------------------------------------
// EvaluateBSDF_Line - Approximation with Linearly Transformed Cosines
//-----------------------------------------------------------------------------

DirectLighting	EvaluateBSDF_Line( LightLoopContext lightLoopContext,
									float3 V, PositionInputs posInput,
									PreLightData preLightData, LightData lightData, BSDFData bsdfData, BakeLightingData bakeLightingData ) {
	DirectLighting lighting;
	ZERO_INITIALIZE(DirectLighting, lighting);

	//NEWLITTODO

	return lighting;
}

//-----------------------------------------------------------------------------
// EvaluateBSDF_Area - Approximation with Linearly Transformed Cosines
//-----------------------------------------------------------------------------

// #define ELLIPSOIDAL_ATTENUATION

DirectLighting	EvaluateBSDF_Rect( LightLoopContext lightLoopContext,
									float3 V, PositionInputs posInput,
									PreLightData preLightData, LightData lightData, BSDFData bsdfData, BakeLightingData bakeLightingData ) {
	DirectLighting lighting;
	ZERO_INITIALIZE(DirectLighting, lighting);

	//NEWLITTODO

	return lighting;
}

DirectLighting	EvaluateBSDF_Area( LightLoopContext lightLoopContext,
									float3 V, PositionInputs posInput,
									PreLightData preLightData, LightData lightData,
									BSDFData bsdfData, BakeLightingData bakeLightingData ) {

	if (lightData.lightType == GPULIGHTTYPE_LINE) {
		return EvaluateBSDF_Line(lightLoopContext, V, posInput, preLightData, lightData, bsdfData, bakeLightingData);
	} else {
		return EvaluateBSDF_Rect(lightLoopContext, V, posInput, preLightData, lightData, bsdfData, bakeLightingData);
	}
}

//-----------------------------------------------------------------------------
// EvaluateBSDF_SSLighting for screen space lighting
// ----------------------------------------------------------------------------

IndirectLighting	EvaluateBSDF_SSLighting( LightLoopContext lightLoopContext,
												float3 V, PositionInputs posInput,
												PreLightData preLightData, BSDFData bsdfData,
												EnvLightData envLightData,
												int GPUImageBasedLightingType,
												inout float hierarchyWeight ) {

	IndirectLighting lighting;
	ZERO_INITIALIZE(IndirectLighting, lighting);

	//NEWLITTODO

	return lighting;
}

//-----------------------------------------------------------------------------
// EvaluateBSDF_Env
// ----------------------------------------------------------------------------

// _preIntegratedFGD and _CubemapLD are unique for each BRDF
IndirectLighting	EvaluateBSDF_Env(  LightLoopContext lightLoopContext,
										float3 V, PositionInputs posInput,
										PreLightData preLightData, EnvLightData lightData, BSDFData bsdfData,
										int influenceShapeType, int GPUImageBasedLightingType,
										inout float hierarchyWeight ) {

	IndirectLighting lighting;
	ZERO_INITIALIZE(IndirectLighting, lighting);

	//NEWLITTODO

	return lighting;
}

//-----------------------------------------------------------------------------
// PostEvaluateBSDF
// ----------------------------------------------------------------------------

void	PostEvaluateBSDF(  LightLoopContext lightLoopContext,
							float3 V, PositionInputs posInput,
							PreLightData preLightData, BSDFData bsdfData, BakeLightingData bakeLightingData, AggregateLighting lighting,
							out float3 diffuseLighting, out float3 specularLighting ) {
	// Apply the albedo to the direct diffuse lighting and that's about it.
	// diffuse lighting has already had the albedo applied in GetBakedDiffuseLighting().
//	diffuseLighting = bsdfData.diffuseColor * lighting.direct.diffuse + bakeLightingData.bakeDiffuseLighting;
	diffuseLighting = float3( 1, 0.3, 0.01 ) * lighting.direct.diffuse + bakeLightingData.bakeDiffuseLighting;
	specularLighting = lighting.direct.specular; // should be 0 for now.

#ifdef DEBUG_DISPLAY

	if ( _DebugLightingMode != 0 ) {
		bool keepSpecular = false;

		switch ( _DebugLightingMode ) {
		case DEBUGLIGHTINGMODE_LUX_METER:
			diffuseLighting = lighting.direct.diffuse + bakeLightingData.bakeDiffuseLighting;
			break;

		case DEBUGLIGHTINGMODE_INDIRECT_DIFFUSE_OCCLUSION:
//			diffuseLighting = aoFactor.indirectAmbientOcclusion;
			break;

		case DEBUGLIGHTINGMODE_INDIRECT_SPECULAR_OCCLUSION:
//			diffuseLighting = aoFactor.indirectSpecularOcclusion;
			break;

		case DEBUGLIGHTINGMODE_SCREEN_SPACE_TRACING_REFRACTION:
//			if (_DebugLightingSubMode != DEBUGSCREENSPACETRACING_COLOR)
//				diffuseLighting = lighting.indirect.specularTransmitted;
//			else
//				keepSpecular = true;
			break;

		case DEBUGLIGHTINGMODE_SCREEN_SPACE_TRACING_REFLECTION:
//			if (_DebugLightingSubMode != DEBUGSCREENSPACETRACING_COLOR)
//				diffuseLighting = lighting.indirect.specularReflected;
//			else
//				keepSpecular = true;
			break;
		}

		if ( !keepSpecular )
			specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting

	} else if ( _DebugMipMapMode != DEBUGMIPMAPMODE_NONE ) {
		diffuseLighting = bsdfData.diffuseColor;
		specularLighting = float3(0.0, 0.0, 0.0); // Disable specular lighting
	}


//diffuseLighting = float3( 1, 0, 0 );


#endif
}

#endif // #ifdef HAS_LIGHTLOOP
