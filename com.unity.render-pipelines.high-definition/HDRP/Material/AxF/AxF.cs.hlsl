//
// This file was automatically generated. Please don't edit by hand.
//

#ifndef AXF_CS_HLSL
#define AXF_CS_HLSL
//
// UnityEngine.Experimental.Rendering.HDPipeline.AxF+SurfaceData:  static fields
//
#define DEBUGVIEW_AXF_SURFACEDATA_DIFFUSE_COLOR (1300)
#define DEBUGVIEW_AXF_SURFACEDATA_NORMAL (1301)
#define DEBUGVIEW_AXF_SURFACEDATA_NORMAL_VIEW_SPACE (1302)
#define DEBUGVIEW_AXF_SURFACEDATA_FRESNEL_F0 (1303)
#define DEBUGVIEW_AXF_SURFACEDATA_SPECULAR_COLOR (1304)
#define DEBUGVIEW_AXF_SURFACEDATA_SPECULAR_LOBE (1305)

//
// UnityEngine.Experimental.Rendering.HDPipeline.AxF+BSDFData:  static fields
//
#define DEBUGVIEW_AXF_BSDFDATA_DIFFUSE_COLOR (1400)
#define DEBUGVIEW_AXF_BSDFDATA_NORMAL_WS (1401)
#define DEBUGVIEW_AXF_BSDFDATA_NORMAL_VIEW_SPACE (1402)
#define DEBUGVIEW_AXF_BSDFDATA_FRESNEL_F0 (1403)
#define DEBUGVIEW_AXF_BSDFDATA_SPECULAR_COLOR (1404)
#define DEBUGVIEW_AXF_BSDFDATA_ROUGHNESS (1405)

// Generated from UnityEngine.Experimental.Rendering.HDPipeline.AxF+SurfaceData
// PackingRules = Exact
struct SurfaceData
{
    float3 diffuseColor;
    float3 normalWS;
    float3 fresnelF0;
    float3 specularColor;
    float3 specularLobe;
};

// Generated from UnityEngine.Experimental.Rendering.HDPipeline.AxF+BSDFData
// PackingRules = Exact
struct BSDFData
{
    float3 diffuseColor;
    float3 normalWS;
    float3 fresnelF0;
    float3 specularColor;
    float3 roughness;
};

//
// Debug functions
//
void GetGeneratedSurfaceDataDebug(uint paramId, SurfaceData surfacedata, inout float3 result, inout bool needLinearToSRGB)
{
    switch (paramId)
    {
        case DEBUGVIEW_AXF_SURFACEDATA_DIFFUSE_COLOR:
            result = surfacedata.diffuseColor;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_SURFACEDATA_NORMAL:
            result = surfacedata.normalWS * 0.5 + 0.5;
            break;
        case DEBUGVIEW_AXF_SURFACEDATA_NORMAL_VIEW_SPACE:
            result = surfacedata.normalWS * 0.5 + 0.5;
            break;
        case DEBUGVIEW_AXF_SURFACEDATA_FRESNEL_F0:
            result = surfacedata.fresnelF0;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_SURFACEDATA_SPECULAR_COLOR:
            result = surfacedata.specularColor;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_SURFACEDATA_SPECULAR_LOBE:
            result = surfacedata.specularLobe;
            needLinearToSRGB = true;
            break;
    }
}

//
// Debug functions
//
void GetGeneratedBSDFDataDebug(uint paramId, BSDFData bsdfdata, inout float3 result, inout bool needLinearToSRGB)
{
    switch (paramId)
    {
        case DEBUGVIEW_AXF_BSDFDATA_DIFFUSE_COLOR:
            result = bsdfdata.diffuseColor;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_BSDFDATA_NORMAL_WS:
            result = bsdfdata.normalWS * 0.5 + 0.5;
            break;
        case DEBUGVIEW_AXF_BSDFDATA_NORMAL_VIEW_SPACE:
            result = bsdfdata.normalWS * 0.5 + 0.5;
            break;
        case DEBUGVIEW_AXF_BSDFDATA_FRESNEL_F0:
            result = bsdfdata.fresnelF0;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_BSDFDATA_SPECULAR_COLOR:
            result = bsdfdata.specularColor;
            needLinearToSRGB = true;
            break;
        case DEBUGVIEW_AXF_BSDFDATA_ROUGHNESS:
            result = bsdfdata.roughness;
            needLinearToSRGB = true;
            break;
    }
}


#endif
