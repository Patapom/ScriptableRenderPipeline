TEXTURE2D(_PreIntegratedFGD);

// For image based lighting, a part of the BSDF is pre-integrated.
// This is done both for specular GGX height-correlated and DisneyDiffuse
// reflectivity is  Integral{(BSDF_GGX / F) - use for multiscattering
void GetPreIntegratedFGDGGXAndDisneyDiffuse(float NdotV, float perceptualRoughness, float3 fresnel0, out float3 GGXSpecularFGD, out float disneyDiffuseFGD, out float reflectivity)
{
    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD, s_linear_clamp_sampler, float2(NdotV, perceptualRoughness), 0).xyz;

    // Pre-integrate GGX FGD
    // Integral{BSDF * <N,L> dw} =
    // Integral{(F0 + (1 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
    // (1 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
    // (1 - F0) * x + F0 * y = lerp(x, y, F0)
    GGXSpecularFGD = lerp(preFGD.xxx, preFGD.yyy, fresnel0);

    // Pre integrate DisneyDiffuse FGD:
    // z = DisneyDiffuse
    // Remap from the [0, 1] to the [0.5, 1.5] range.
    disneyDiffuseFGD = preFGD.z + 0.5;

    reflectivity = preFGD.y;
}

///////////////////////////////////////////////////////////////////////////////////////////
// BMAYAUX (18/05/28) Ward BRDF used by the AxF shader

// For image based lighting, a part of the BSDF is pre-integrated.
// This is done both for specular GGX height-correlated and DisneyDiffuse
// _reflectivity is  Integral{(BSDF_GGX / F) - use for multiscattering
void GetPreIntegratedFGDWard( float _NdotV, float _perceptualRoughness, float3 _F0, out float3 _specularFGD, out float _diffuseFGD, out float _reflectivity ) {

    float3 preFGD = SAMPLE_TEXTURE2D_LOD(_PreIntegratedFGD, s_linear_clamp_sampler, float2(_NdotV, _perceptualRoughness), 0).xyz;

    // Pre-integrate GGX FGD
    // Integral{BSDF * <N,L> dw} =
    // Integral{(F0 + (1 - F0) * (1 - <V,H>)^5) * (BSDF / F) * <N,L> dw} =
    // (1 - F0) * Integral{(1 - <V,H>)^5 * (BSDF / F) * <N,L> dw} + F0 * Integral{(BSDF / F) * <N,L> dw}=
    // (1 - F0) * x + F0 * y = lerp(x, y, F0)
    _specularFGD = lerp(preFGD.xxx, preFGD.yyy, _F0);

    // Pre integrate DisneyDiffuse FGD:
    // z = DisneyDiffuse
    // Remap from the [0, 1] to the [0.5, 1.5] range.
    _diffuseFGD = preFGD.z + 0.5;

    _reflectivity = preFGD.y;
}
