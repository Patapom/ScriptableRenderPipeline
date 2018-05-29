using UnityEngine;
using System;

//-----------------------------------------------------------------------------
// structure definition
//-----------------------------------------------------------------------------
namespace UnityEngine.Experimental.Rendering.HDPipeline
{
	public class AxF : RenderPipelineMaterial
	{
		//-----------------------------------------------------------------------------
		// SurfaceData
		//-----------------------------------------------------------------------------

		// Main structure that store the user data (i.e user input of master node in material graph)
		[GenerateHLSL(PackingRules.Exact, false, true, 1300)]
		public struct SurfaceData {

			[SurfaceDataAttributes("Diffuse Color", false, true)]
			public Vector3 diffuseColor;

			[SurfaceDataAttributes(new string[]{"Normal", "Normal View Space"}, true)]
			public Vector3 normalWS;

			[SurfaceDataAttributes("Fresnel F0", false, true)]
			public Vector3 fresnelF0;

			[SurfaceDataAttributes("Specular Color", false, true)]
			public Vector3 specularColor;

			[SurfaceDataAttributes("Specular Lobe", false, true)]
			public Vector3 specularLobe;
		};

		//-----------------------------------------------------------------------------
		// BSDFData
		//-----------------------------------------------------------------------------

		[GenerateHLSL(PackingRules.Exact, false, true, 1400)]
		public struct BSDFData {

			[SurfaceDataAttributes("", false, true)]
			public Vector3	diffuseColor;
            
			[SurfaceDataAttributes(new string[] { "Normal WS", "Normal View Space" }, true)]
			public Vector3	normalWS;

			[SurfaceDataAttributes("", false, true)]
			public Vector3	fresnelF0;

			[SurfaceDataAttributes("", false, true)]
			public Vector3	specularColor;

			[SurfaceDataAttributes("", false, true)]
			public Vector3	roughness;
		};
	}
}
