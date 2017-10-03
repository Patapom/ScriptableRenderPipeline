//-----------------------------------------------------------------------------
// SurfaceData and BSDFData
//-----------------------------------------------------------------------------

// SurfaceData is define in Lit.cs which generate Lit.cs.hlsl
#include "Hair.cs.hlsl"

#define MATERIALID_LIT_ANISO 200
#define LIT_DIFFUSE_LAMBERT_BRDF
#define baseColor diffuseColor // Just to help to compile without to have to rewrite all the code
#include "../LightEvaluationShare1.hlsl"

//-----------------------------------------------------------------------------
// conversion function for forward
//-----------------------------------------------------------------------------

BSDFData ConvertSurfaceDataToBSDFData(SurfaceData surfaceData)
{
    ApplyDebugToSurfaceData(surfaceData);

    BSDFData bsdfData;
    ZERO_INITIALIZE(BSDFData, bsdfData);

    bsdfData.diffuseColor = surfaceData.diffuseColor;
    bsdfData.specularOcclusion = surfaceData.specularOcclusion;
    bsdfData.normalWS = surfaceData.normalWS;

    //NOTE: On Hair UI side, we use slider for roughness. So not necesarry to invert.
    bsdfData.perceptualRoughness = lerp(0.4,1.5,surfaceData.perceptualSmoothness);//PerceptualSmoothnessToPerceptualRoughness(surfaceData.perceptualSmoothness);
    bsdfData.roughness = PerceptualRoughnessToRoughness(bsdfData.perceptualRoughness);

    bsdfData.fresnel0 = 1;

    bsdfData.tangentWS   = surfaceData.tangentWS;
    bsdfData.bitangentWS = cross(surfaceData.normalWS, surfaceData.tangentWS);
    ConvertAnisotropyToRoughness(bsdfData.roughness, surfaceData.anisotropy, bsdfData.roughnessT, bsdfData.roughnessB);
    bsdfData.anisotropy = surfaceData.anisotropy;

	bsdfData.isFrontFace = surfaceData.isFrontFace;

    bsdfData.materialId = MATERIALID_LIT_ANISO;

    return bsdfData;
}

//-----------------------------------------------------------------------------
// bake lighting function
//-----------------------------------------------------------------------------

// GetBakedDiffuseLigthing function compute the bake lighting + emissive color to be store in emissive buffer (Deferred case)
// In forward it must be add to the final contribution.
// This function require the 3 structure surfaceData, builtinData, bsdfData because it may require both the engine side data, and data that will not be store inside the gbuffer.
float3 GetBakedDiffuseLigthing(SurfaceData surfaceData, BuiltinData builtinData, BSDFData bsdfData, PreLightData preLightData)
{
    // Premultiply bake diffuse lighting information with DisneyDiffuse pre-integration
    return builtinData.bakeDiffuseLighting * preLightData.diffuseFGD * surfaceData.ambientOcclusion * bsdfData.diffuseColor + builtinData.emissiveColor;
}

//-----------------------------------------------------------------------------
// light transport functions
//-----------------------------------------------------------------------------

LightTransportData GetLightTransportData(SurfaceData surfaceData, BuiltinData builtinData, BSDFData bsdfData)
{
    LightTransportData lightTransportData;

    // diffuseColor for lightmapping should basically be diffuse color.
    // But rough metals (black diffuse) still scatter quite a lot of light around, so
    // we want to take some of that into account too.

    lightTransportData.diffuseColor = bsdfData.diffuseColor;
    lightTransportData.emissiveColor = builtinData.emissiveColor;

    return lightTransportData;
}

//-----------------------------------------------------------------------------
// LightLoop related function (Only include if required)
// HAS_LIGHTLOOP is define in Lighting.hlsl
//-----------------------------------------------------------------------------

#ifdef HAS_LIGHTLOOP

//http://web.engr.oregonstate.edu/~mjb/cs519/Projects/Papers/HairRendering.pdf
float3 ShiftTangent(float3 T, float3 N, float shift)
{
    float3 shiftedT = T + N * (shift - 0.5)*2;
    return normalize(shiftedT);
}

float3 KajiyaKaySpecular(float3 H, float3 V, float3 N, float3 T, float shift, float roughness)
{
	// We can rewrite specExp from exp2(10 * (1.0 - roughness)) in order
	// to remove the need to take the square root of sinTH
	float specExp = exp2(9 - 10*roughness);
	
	float dotTH = dot (T, H);
	float sinTHSq = (saturate(1.0 - (dotTH * dotTH)));

	float dirAttn = clamp(dotTH + 1, 0, 1);

	return dirAttn * pow (sinTHSq, specExp) ;	
}

//-----------------------------------------------------------------------------
// BSDF share between directional light, punctual light and area light (reference)
//-----------------------------------------------------------------------------

void BSDF(  float3 V, float3 L, float3 positionWS, PreLightData preLightData, BSDFData bsdfData,
            out float3 diffuseLighting,
            out float3 specularLighting)
{
    float NdotL    = saturate(dot(bsdfData.normalWS, L));
    float NdotV    = preLightData.NdotV;
    float LdotV    = dot(L, V);
    float invLenLV = rsqrt(abs(2 + 2 * LdotV));    // invLenLV = rcp(length(L + V))
    float NdotH    = saturate((NdotL + NdotV) * invLenLV);
    float LdotH    = saturate(invLenLV + invLenLV * LdotV);

    //float3 F = F_Schlick(bsdfData.fresnel0, LdotH);

    float Vis;
    float D;

    //Must shift with bitangent and not tangent?
    float3 B1 = ShiftTangent(bsdfData.bitangentWS, bsdfData.normalWS, _PrimarySpecularShift);
    float3 B2 = ShiftTangent(bsdfData.bitangentWS, bsdfData.normalWS, _SecondarySpecularShift);

    // TODO: this way of handling aniso may not be efficient, or maybe with material classification, need to check perf here
    // Maybe always using aniso maybe a win ?
    float3 H = (L + V) * invLenLV;
    // For anisotropy we must not saturate these values


    float TdotH = dot(bsdfData.tangentWS, H);
    float TdotL = dot(bsdfData.tangentWS, L);
    float BdotH = dot(B2, H);
    float BdotL = dot(B2, L);
    float BdotV = dot(B2, V);
    float3 transL=L+bsdfData.normalWS*0.3;
	bsdfData.roughnessT = ClampRoughnessForAnalyticalLights(bsdfData.roughnessT);
    bsdfData.roughnessB = ClampRoughnessForAnalyticalLights(bsdfData.roughnessB);

    // TODO: Do comparison between this correct version and the one from isotropic and see if there is any visual difference
    Vis = V_SmithJointGGXAniso( preLightData.TdotV, preLightData.BdotV, NdotV, TdotL, BdotL, NdotL,
                                bsdfData.roughnessT, bsdfData.roughnessB);

    D = D_GGXAniso(TdotH, BdotH, NdotH, bsdfData.roughnessT, bsdfData.roughnessB);
    float3 hairSpec1 =	0.5*_PrimarySpecular*KajiyaKaySpecular(H, V, bsdfData.normalWS, B1, _PrimarySpecularShift, 0.5*bsdfData.roughness)*lerp(1,_SpecularTint,0.3);
	float3 hairSpec2 =	_SecondarySpecular*(Vis * D)*lerp(bsdfData.diffuseColor,_SpecularTint,0.5);	
    specularLighting = 0.15*bsdfData.specularOcclusion*(hairSpec1 + hairSpec2);
	specularLighting *= (bsdfData.isFrontFace ? 1.0 : 0.0); //Disable backfacing specular for now. Look into having a flipped normal entirely.
	float scatterFresnel = 3*dot(V,-transL)*dot(V,-transL)*dot(V,-transL)*(1.0 - NdotV)*(1.0 - NdotL)+ 0.5*(1-NdotV)*(1-NdotV)*(1-NdotV);
	float transAmount = _Scatter*scatterFresnel;
	float3 transColor = saturate(transAmount * float3(0.992, 0.808, 0.518)*bsdfData.specularOcclusion);
    float  diffuseTerm = Lambert();
    diffuseLighting = bsdfData.diffuseColor * diffuseTerm+transColor;
}

#endif // #ifdef HAS_LIGHTLOOP

#include "../LightEvaluationShare2.hlsl"
