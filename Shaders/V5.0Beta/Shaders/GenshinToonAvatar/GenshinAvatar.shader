Shader "GenshinCelShaderURP/V5.0Beta"
{
    Properties
    {
        [Header(General)]
        [KeywordEnum(Body, Face)] _RenderType("Render Type", Float) = 0.0
        [KeywordEnum(R, A)] _UseFaceLightMapChannel("Use Face Lightmap Channel", Float) = 1.0
        [Toggle] _UseCoolShadowColorOrTex("Use Cool Ramp Shadow", Float) = 0.0
        [Toggle(_BACKFACEUV2_ON)] _UseBackFaceUV2("Use Back Face UV2 (Default NO)", Float) = 0
        _FrontFaceTintColor("Front face tint color (Default white)", Color) = (1.0, 1.0, 1.0, 1.0)
        _BackFaceTintColor("Back face tint color (Default white)", Color) = (1.0, 1.0, 1.0, 1.0)
        [KeywordEnum(None, Flicker, Emission, AlphaTest)] _MainTexAlphaUse("Diffuse Texture Alpha Use", Float) = 0.0
        _Alpha("Alpha (Default 1)", Range(0, 1)) = 1
        _AlphaClip("Alpha clip (Default 0.5)", Range(0.0, 1.0)) = 0.5
        _MainTexCutOff("Alpha clip (MainTex)", Range(0.0, 1.0)) = 0.5

        [Header(Main Lighting)]
        _MainTex("Diffuse Texture", 2D) = "white" { }
        _ilmTex("ilm Texture", 2D) = "white" { }
        _RampTex("Ramp Texture", 2D) = "white" { }
        _BrightFac("Bright Factor", Float) = 0.99
        _GreyFac("Gray Factor", Float) = 1.08
        _DarkFac("Dark Factor", Float) = 0.55
        [Toggle(_MAINLIGHT_SHADOWATTENUATION_ON)] _UseMainLightshadowAttenuation("Use mainLight shadow attenuation", Float) = 0

        [Header(Indirect Lighting)]
        _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)", Range(0, 1)) = 0
        _IndirectLightIntensity("Indirect light intensity (Default 1)", Range(0, 2)) = 1
        _IndirectLightUsage("Indirect light color usage (Default 0.5)", Range(0, 1)) = 0.5

        [Header(Face Settings)]
        _FaceShadowMap("Face SDF Texture", 2D) = "white" { }
        _FaceMapTex("FaceMap Texture", 2D) = "white" { }
        _FaceShadowOffset("Face Shadow Offset", range(-1.0, 1.0)) = 0.0
        _FaceShadowTransitionSoftness("Face shadow transition softness (Default 0.05)", Range(0, 1)) = 0.05

        [Header(ColorGrading)]
        _LightAreaColorTint("Light Area Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _DarkShadowColor("Dark Shadow Color Tint", Color) = (0.75, 0.75, 0.75, 1.0)
        _CoolDarkShadowColor("Cool Dark Shadow Color Tint", Color) = (0.5, 0.5, 0.65, 1.0)
        _BrightAreaShadowFac("Bright Area Shadow Factor", Range(0, 1)) = 1

        [Header(Ramp Settings)]
        [IntRange] _RampIndex0("RampIndex_1.0", Range(1, 5)) = 1
        [IntRange] _RampIndex1("RampIndex_0.7", Range(1, 5)) = 4
        [IntRange] _RampIndex2("RampIndex_0.5", Range(1, 5)) = 3
        [IntRange] _RampIndex3("RampIndex_0.3", Range(1, 5)) = 5
        [IntRange] _RampIndex4("RampIndex_0.0", Range(1, 5)) = 2

        [Header(Normal)]
        [Toggle(_NORMAL_MAP_ON)] _UseNormalMap("Use Normal Map (Default NO)", Float) = 0
        _BumpFactor("Bump Scale (Default 1)", Float) = 1.0
        [Normal] _NormalMap("Normal Map (Default black)", 2D) = "bump" { }

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular ("Enable Specular (Default YES)", Float) = 1
        [Toggle] _MetalMaterial ("Enable Metallic", Range(0.0, 1.0)) = 1.0
        _MTMap("Metallic Matcap", 2D)= "white"{ }
        [Toggle] _MTUseSpecularRamp ("Enable Metal Specular Ramp", Float) = 0.0
        _MTSpecularRamp("Specular Ramp", 2D)= "white"{ }
        _MTMapBrightness ("Metallic Matcap Brightness", Float) = 3.0
        _MTShininess ("Metallic Specular Shininess", Float) = 90.0
        _MTSpecularScale ("Metallic Specular Scale", Float) = 15.0
        _MTMapTileScale ("Metallic Matcap Tile Scale", Range(0.0, 2.0)) = 1.0
        _MTSpecularAttenInShadow ("Metallic Specular Power in Shadow", Range(0.0, 1.0)) = 0.2
        _MTSharpLayerOffset ("Metallic Sharp Layer Offset", Range(0.001, 1.0)) = 1.0
        // Metal Color
        _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTSharpLayerColor ("Metallic Sharp Layer Color", Color) = (1.0, 1.0, 1.0, 1.0)
        // Specular
        [Toggle] _SpecularHighlights ("Enable Specular Highlights", Float) = 0.0
        _Shininess ("Shininess 1", Float) = 10
        _Shininess2 ("Shininess 2", Float) = 10
        _Shininess3 ("Shininess 3", Float) = 10
        _Shininess4 ("Shininess 4", Float) = 10
        _Shininess5 ("Shininess 5", Float) = 10
        _SpecMulti ("Specular Multiplier 1", Float) = 0.1
        _SpecMulti2 ("Specular Multiplier 2", Float) = 0.1
        _SpecMulti3 ("Specular Multiplier 3", Float) = 0.1
        _SpecMulti4 ("Specular Multiplier 4", Float) = 0.1
        _SpecMulti5 ("Specular Multiplier 5", Float) = 0.1
        _SpecularColor ("Specular Color 1", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor2 ("Specular Color 2", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor3 ("Specular Color 3", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor4 ("Specular Color 4", Color) = (1.0, 1.0, 1.0, 1.0)
        _SpecularColor5 ("Specular Color 5", Color) = (1.0, 1.0, 1.0, 1.0)

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)",float) = 1
        _RimLightWidth("Rim light width (Default 1)",Range(0, 10)) = 1
        _RimLightThreshold("Rin light threshold (Default 0.05)",Range(-1, 1)) = 0.05
        _RimLightFadeout("Rim light fadeout (Default 1)",Range(0.01, 1)) = 1
        [HDR] _RimLightTintColor("Rim light tint colar (Default white)",Color) = (1,1,1)
        _RimLightBrightness("Rim light brightness (Default 1)",Range(0, 10)) = 1
        _RimColor ("Rim Light Color", Color)   = (1, 1, 1, 1)
        _RimColor1 ("Rim Light Color 1", Color)  = (1, 1, 1, 1)
        _RimColor2 ("Rim Light Color 2", Color)  = (1, 1, 1, 1)
        _RimColor3 ("Rim Light Color 3", Color)  = (1, 1, 1, 1)
        _RimColor4 ("Rim Light Color 4", Color) = (1, 1, 1, 1)
        _RimColor5 ("Rim Light Color 5", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)", Float) = 0
        _EmissionMixBaseColorFac("Emission mix base color factor (Default 1)", Range(0, 1)) = 1
        _EmissionTintColor("Emission tint color (Default white)", Color) = (1, 1, 1, 1)
        _EmissionScaler("Emission Scaler", Range(1.0, 10.0)) = 1.0

        [Header(Outline)]
        [Toggle] _EnableOutline("Enable Outline (Default YES)", Float) = 1
        [KeywordEnum(Normal, Tangent, UV2)] _OutlineNormalChannel("Outline Normal Channel", Float) = 0
        [Toggle(_OUTLINE_CUSTOM_COLOR_ON)] _UseCustomOutlineCol("Use Custom outline Color", Float) = 0
        _OutlineDefaultColor("Outline Default Color", Color) = (0.5, 0.5, 0.5, 1)
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineColor1("Outline Color 1", Color) = (0, 0, 0, 1)
        _OutlineColor2("Outline Color 2", Color) = (0, 0, 0, 1)
        _OutlineColor3("Outline Color 3", Color) = (0, 0, 0, 1)
        _OutlineColor4("Outline Color 4", Color) = (0, 0, 0, 1)
        _OutlineColor5("Outline Color 5", Color) = (0, 0, 0, 1)

        [Toggle] _FaceMaterial("Is Face Material Outline", Float) = 0
        _OutlineWidth("OutlineWidth (World Space)", Range(0, 1)) = 0.1
        _OutlineScale("OutlineScale (Default 1)", Float) = 1
        _OutlineWidthParams("Outline Width Params", Vector) = (0, 1, 0, 1)
        _OutlineZOffset("Outline Z Offset", Float) = 0
        _ScreenOffset("Screen Offset", Vector) = (0, 0, 0, 0)

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode (Default Back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColor("Core Pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColor("Core Pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlpha("Core Pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlpha("Core Pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite (Default On)", Float) = 1

    }

    SubShader
    {
        HLSLINCLUDE
        #include "../../ShaderLibrary/AvatarGenshinInput.hlsl"
        ENDHLSL

        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "GenshinCharacter_CorePass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull[_CullMode]
            Blend[_SrcBlendModeColor] [_DstBlendModeColor], [_SrcBlendModeAlpha] [_DstBlendModeAlpha]
            ZWrite[_ZWrite]

            HLSLPROGRAM
            #pragma vertex GenshinStyleVertex
            #pragma fragment GenshinStyleFragment

            #pragma multi_compile _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            // #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _LIGHT_LAYERS

            #pragma shader_feature_local _ _MAINTEXALPHAUSE_NONE _MAINTEXALPHAUSE_FLICKER _MAINTEXALPHAUSE_EMISSION _MAINTEXALPHAUSE_ALPHATEST
            #pragma shader_feature_local _ _RENDERTYPE_BODY _RENDERTYPE_FACE
            #pragma shader_feature_fragment _ _USEFACELIGHTMAPCHANNEL_R _USEFACELIGHTMAPCHANNEL_A
            #pragma shader_feature_local _EMISSION_ON
            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON
            #pragma shader_feature_local _MAINLIGHT_SHADOWATTENUATION_ON
            #pragma shader_feature_local_fragment _NORMAL_MAP_ON
            #pragma shader_feature_local _SPECULAR_ON
            #pragma shader_feature_local _RIM_LIGHTING_ON

            #include "../../ShaderLibrary/AvatarGenshinPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "GenshinCharacter_BackFacingOutline"
            Tags
            {
                "LightMode" = "SRPDefaultUnlit"
            }

            Cull Front // Cull Front is a must for extra pass outline method
            ZWrite[_ZWrite]

            HLSLPROGRAM
            #pragma vertex BackFaceOutlineVertex
            #pragma fragment BackFaceOutlineFragment
            #pragma shader_feature_local _OUTLINE_CUSTOM_COLOR_ON
            #pragma shader_feature_local _MODEL_GAME _MODEL_MMD
            #pragma shader_feature_local_fragment _ _BACKFACEUV2_ON
            #pragma shader_feature_local _OUTLINENORMALCHANNEL_NORMAL _OUTLINENORMALCHANNEL_TANGENT _OUTLINENORMALCHANNEL_UV2

            // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
            #include "../../ShaderLibrary/AvatarGenshinOutlinePass.hlsl"

            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_CullMode]

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Universal Pipeline keywords

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On

            HLSLPROGRAM
            #pragma target 2.0

            // -------------------------------------
            // Shader Stages
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _ALPHATEST_ON

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT // forward-only variant
            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}