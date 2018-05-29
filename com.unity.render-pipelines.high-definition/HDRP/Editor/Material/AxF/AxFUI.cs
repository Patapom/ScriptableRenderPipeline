using System;
using UnityEngine;
using UnityEngine.Experimental.Rendering;

namespace UnityEditor.Experimental.Rendering.HDPipeline
{
	class AxFGUI : BaseUnlitGUI {
 		protected static class Styles {
 			public static string InputsText = "Inputs";
// 
// 			public static GUIContent baseColorText = new GUIContent( "Base Color + Opacity", "Albedo (RGB) and Opacity (A)" );
// 
// // 			public static GUIContent emissiveText = new GUIContent("Emissive Color", "Emissive");
// // 			public static GUIContent emissiveIntensityText = new GUIContent("Emissive Intensity", "Emissive");
// // 			public static GUIContent albedoAffectEmissiveText = new GUIContent("Albedo Affect Emissive", "Specifies whether or not the emissive color is multiplied by the albedo.");

			public static GUIContent	diffuseColorText = new GUIContent( "Diffuse Color" );
			public static GUIContent	specularColorText = new GUIContent( "Specular Color" );
			public static GUIContent	specularLobeText = new GUIContent( "Specular Lobe" );
			public static GUIContent	fresnelText = new GUIContent( "Fresnel" );
			public static GUIContent	normalText = new GUIContent( "Normal" );
 		}

        public enum	BRDF_TYPE {
            SVBRDF,
            BTF,
			CAR_PAINT
        }
		static readonly string[]	BRDFTypeNames = Enum.GetNames(typeof(BRDF_TYPE));

		protected MaterialProperty	m_BRDFType = null;

		protected MaterialProperty	m_diffuseColorMap = null;
		protected MaterialProperty	m_specularColorMap = null;
		protected MaterialProperty	m_specularLobeMap = null;
		protected MaterialProperty	m_fresnelMap = null;
		protected MaterialProperty	m_normalMap = null;


// 		protected MaterialProperty	m_baseColor = null;
// 		protected MaterialProperty	m_baseColorMap = null;

// 		protected MaterialProperty emissiveColor = null;
// 		protected MaterialProperty emissiveColorMap = null;
// 		protected MaterialProperty emissiveIntensity = null;
// 		protected MaterialProperty albedoAffectEmissive = null;


		override protected void FindMaterialProperties( MaterialProperty[] props ) {

 			m_BRDFType = FindProperty( "_BRDFType", props );

			m_diffuseColorMap = FindProperty( "_SVBRDF_DiffuseColor", props );
			m_specularColorMap = FindProperty( "_SVBRDF_SpecularColor", props );
			m_specularLobeMap = FindProperty( "_SVBRDF_SpecularLobe", props );
			m_fresnelMap = FindProperty( "_SVBRDF_Fresnel", props );
			m_normalMap = FindProperty( "_SVBRDF_Normal", props );

// 			m_baseColor = FindProperty( "_BaseColor", props );
// 			m_baseColorMap = FindProperty( "_BaseColorMap", props );

// 			emissiveColor = FindProperty( "_EmissiveColor" , props );
// 			emissiveColorMap = FindProperty( "_EmissiveColorMap", props );
// 			emissiveIntensity = FindProperty( "_EmissiveIntensity", props );
// 			albedoAffectEmissive = FindProperty( "_AlbedoAffectEmissive", props );
		}

		protected override void MaterialPropertiesGUI( Material _material ) {
			EditorGUILayout.LabelField( Styles.InputsText, EditorStyles.boldLabel );

            BRDF_TYPE	BRDFType = (BRDF_TYPE) m_BRDFType.floatValue;
            BRDFType = (BRDF_TYPE) EditorGUILayout.Popup( "BRDF Type", (int) BRDFType, BRDFTypeNames );
			m_BRDFType.floatValue = (float) BRDFType;

			switch ( BRDFType ) {
				case BRDF_TYPE.SVBRDF: {
					EditorGUILayout.Space();
					++EditorGUI.indentLevel;
					EditorGUILayout.LabelField( "CAILLOU!", EditorStyles.boldLabel );

					m_MaterialEditor.TexturePropertySingleLine( Styles.diffuseColorText, m_diffuseColorMap );
					m_MaterialEditor.TexturePropertySingleLine( Styles.specularColorText, m_specularColorMap );
					m_MaterialEditor.TexturePropertySingleLine( Styles.specularLobeText, m_specularLobeMap );
					m_MaterialEditor.TexturePropertySingleLine( Styles.fresnelText, m_fresnelMap );
					m_MaterialEditor.TexturePropertySingleLine( Styles.normalText, m_normalMap );

					--EditorGUI.indentLevel;
					break;
				}
			}


// 			m_MaterialEditor.TexturePropertySingleLine( Styles.baseColorText, m_baseColorMap, m_baseColor );
// 			m_MaterialEditor.TextureScaleOffsetProperty( m_baseColorMap );

// 			m_MaterialEditor.TexturePropertySingleLine(Styles.emissiveText, emissiveColorMap, emissiveColor);
// 			m_MaterialEditor.TextureScaleOffsetProperty(emissiveColorMap);
// 			m_MaterialEditor.ShaderProperty(emissiveIntensity, Styles.emissiveIntensityText);
// 			m_MaterialEditor.ShaderProperty(albedoAffectEmissive, Styles.albedoAffectEmissiveText);

			var surfaceTypeValue = (SurfaceType) surfaceType.floatValue;
			if ( surfaceTypeValue == SurfaceType.Transparent ) {
				EditorGUILayout.Space();
				EditorGUILayout.LabelField( StylesBaseUnlit.TransparencyInputsText, EditorStyles.boldLabel );
				++EditorGUI.indentLevel;

				DoDistortionInputsGUI();

				--EditorGUI.indentLevel;
			}
		}

		protected override void MaterialPropertiesAdvanceGUI( Material _material ) {
		}

		protected override void VertexAnimationPropertiesGUI() {

		}

		protected override bool ShouldEmissionBeEnabled( Material _material ) {
			return false;//_material.GetFloat(kEmissiveIntensity) > 0.0f;
		}

		protected override void SetupMaterialKeywordsAndPassInternal( Material _material ) {
			SetupMaterialKeywordsAndPass( _material );
		}

		// All Setup Keyword functions must be static. It allow to create script to automatically update the shaders with a script if code change
		static public void SetupMaterialKeywordsAndPass( Material _material ) {
			SetupBaseUnlitKeywords( _material );
			SetupBaseUnlitMaterialPass( _material );

//			CoreUtils.SetKeyword(_material, "_EMISSIVE_COLOR_MAP", _material.GetTexture(kEmissiveColorMap));
		}
	}
} // namespace UnityEditor
