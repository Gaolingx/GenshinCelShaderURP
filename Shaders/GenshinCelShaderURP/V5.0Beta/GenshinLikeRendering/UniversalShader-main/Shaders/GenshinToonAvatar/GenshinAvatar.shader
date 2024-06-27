Shader "GenshinCelShaderURP/V5.0Beta"
{
    Properties
    {
        [Header(General)]
        [KeywordEnum(Body, Face)] _RenderType("Render Type", Float) = 0.0
        [KeywordEnum(R, A)] _UseFaceLightMapChannel("Use Face Lightmap Channel", Float) = 1.0
        [Toggle] _UseCoolShadowColorOrTex("Use Cool Ramp Shadow", Float) = 0.0
        _FrontFaceTintColor("Front face tint color (Default white)", Color) = (1.0, 1.0, 1.0, 1.0)
        _BackFaceTintColor("Back face tint color (Default white)", Color) = (1.0, 1.0, 1.0, 1.0)
        [KeywordEnum(None, Flicker, Emission, AlphaTest)] _MainTexAlphaUse("Diffuse Texture Alpha Use", Float) = 0.0
        _Alpha("Alpha (Default 1)", Range(0, 1)) = 1
        _AlphaClip("Alpha clip (Default 0.5)", Range(0.0, 1.0)) = 0.5
        _MainTexCutOff("Alpha clip (MainTex)", Range(0.0, 1.0)) = 0.5

        [Header(Main Lighting)]
        [Toggle(_MAINLIGHT_SHADOWATTENUATION_ON)] _UseMainLightshadowAttenuation("Use mainLight shadow attenuation", Float) = 0
        _MainTex("Diffuse Texture", 2D) = "white" { }
        _ilmTex("ilm Texture", 2D) = "white" { }
        _RampTex("Ramp Texture", 2D) = "white" { }
        _BrightFac("Bright Factor", Float) = 0.99
        _GreyFac("Gray Factor", Float) = 1.08
        _DarkFac("Dark Factor", Float) = 0.55
        _RampAOLerp("Shadow AO Lerp", Range(0.0, 1.0)) = 1.0

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
        _BumpScale("Bump Scale", Float) = 1.0
        [Normal] _NormalMap("Normal Map (Default black)", 2D) = "bump" { }

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular ("Enable Specular (Default YES)", Float) = 1
        [HideInInspector] m_start_reflections("Reflections", Float) = 0
        [HideInInspector] m_start_metallics("Metallics", Int) = 0
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
        [HideInInspector] m_start_metallicscolor("Metallic Colors", Int) = 0
        _MTMapDarkColor ("Metallic Matcap Dark Color", Color) = (0.51, 0.3, 0.19, 1.0)
        _MTMapLightColor ("Metallic Matcap Light Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTShadowMultiColor ("Metallic Matcap Shadow Multiply Color", Color) = (0.78, 0.77, 0.82, 1.0)
        _MTSpecularColor ("Metallic Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MTSharpLayerColor ("Metallic Sharp Layer Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_metallicscolor ("", Int) = 0
        [HideInInspector] m_end_metallics("", Int) = 0
        // Specular 
        [HideInInspector] m_start_specular("Specular Reflections", Int) = 0
        [Toggle] _SpecularHighlights ("Enable Specular", Float) = 0.0
        [HideInInspector] [Toggle] _UseToonSpecular ("Enable Specular", Float) = 0.0
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
        _SpecularColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [HideInInspector] m_end_specular("", Int) = 0
        [HideInInspector] m_end_reflections ("", Float) = 0

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Enable Rim Light (Default YES)", Float) = 1
        [HideInInspector] m_start_rimlight("Rim Light", Float) = 0
        _RimThreshold ("Rim Threshold", Range(0.0, 1.0)) = 0.5
        _RimLightIntensity ("Rim Light Intensity", Float) = 0.25
        _RimLightThickness ("Rim Light Thickness", Range(0.0, 10.0)) = 1.0
        [HideInInspector] m_start_lightingrimcolor("Rimlight Color", Float) = 0
        _RimColor (" Rim Light Color", Color)   = (1, 1, 1, 1)
        _RimColor0 (" Rim Light Color 1", Color)   = (1, 1, 1, 1)
        _RimColor1 (" Rim Light Color 2", Color)  = (1, 1, 1, 1)
        _RimColor2 (" Rim Light Color 3", Color)  = (1, 1, 1, 1)
        _RimColor3 (" Rim Light Color 4", Color)  = (1, 1, 1, 1)
        _RimColor4 (" Rim Light Color 5", Color) = (1, 1, 1, 1)
        [HideInInspector] m_end_lightingrimcolor("", Float) = 0
        [HideInInspector] m_end_rimlight ("", Float) = 0
        [HideInInspector] g_end_light("", Int) = 0
        [HideInInspector] m_end_lightning ("", Float) = 0

        [Header(Emission)]
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)", Float) = 0
        _EmissionMixBaseColorFac("Emission mix base color factor (Default 1)", Range(0, 1)) = 1
        _EmissionTintColor("Emission tint color (Default white)", Color) = (1, 1, 1, 1)
        _EmissionScaler("Emission Scaler", Range(1.0, 10.0)) = 1.0

        [Header(Outline)]
        [Toggle] _EnableOutlineToggle("Enable Outline (Default YES)", Float) = 1
        [HideInInspector] m_start_outlines("Outlines", Float) = 0
        [Enum(None, 0, Normal, 1,  Tangent, 2)] _OutlineType ("Outline Type", Float) = 1.0
        [Toggle] _FallbackOutlines ("Enable Static Outlines", Range(0.0, 1.0)) = 0
        [Toggle] _UseFaceOutline ("Enable Face Outline", Float) = 0.0
        _OutlineWidth ("Outline Width", Float) = 0.03
        _Scale ("Outline Scale", Float) = 0.01
        [Toggle] [HideInInspector] _UseClipPlane ("Use Clip Plane?", Range(0.0, 1.0)) = 0.0
        [HideInInspector] _ClipPlane ("Clip Plane", Vector) = (0.0, 0.0, 0.0, 0.0)
        // Outline Color
        [Toggle(_OUTLINE_CUSTOM_COLOR_ON)] _UseCustomOutlineCol("Use Custom outline Color", Float) = 0
        [HideInInspector] m_start_outlinescolor("Outline Colors", Float) = 0
        _OutlineColor1 ("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor2 ("Outline Color 2", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor3 ("Outline Color 3", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor4 ("Outline Color 4", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor5 ("Outline Color 5", Color) = (0.0, 0.0, 0.0, 1.0)
        [HideInInspector] m_end_outlinescolor ("", Float) = 0
        // Outline Offsets
        [HideInInspector] m_start_outlinesoffset("Outline Offset & Adjustments", Float) = 0
        _OutlineWidthAdjustScales ("Outline Width Adjust Scales", Vector) = (0.01, 0.245, 0.6, 0.0)
        _OutlineWidthAdjustZs ("Outline Width Adjust Zs", Vector) = (0.001, 2.0, 6.0, 0.0)
        _MaxOutlineZOffset ("Max Z-Offset", Float) = 1.0
        [HideInInspector] m_end_outlinesoffset ("", Float) = 0
        [HideInInspector] m_end_outlines ("", Float) = 0

        [Header(Debug)]
        _DebugValue01("Debug Value 0-1", Range(0.0, 1.0)) = 0.0

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode (Default Back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeColor("Core Pass src blend mode color (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeColor("Core Pass dst blend mode color (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendModeAlpha("Core Pass src blend mode alpha (Default One)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendModeAlpha("Core Pass dst blend mode alpha (Default Zero)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp("BlendOp (Default Add)", Float) = 0
        [Enum(Off, 0, On, 1)] _ZWrite("ZWrite (Default On)", Float) = 1
        _StencilRef("Stencil reference (Default 0)", Range(0, 255)) = 0
        _StencilReadMask("Stencil Read Mask (Default 255)", Range(0, 255)) = 255
        _StencilWriteMask("Stencil Write Mask (Default 255)", Range(0, 255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil comparison (Default disabled)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil pass comparison (Default keep)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil fail comparison (Default keep)", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil z fail comparison (Default keep)", Int) = 0

    }
    SubShader
    {
        HLSLINCLUDE
        #include "../../ShaderLibrary/AvatarGenshinInput.hlsl"
        ENDHLSL
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        LOD 100

        Pass
        {
            Name "GenshinStyleBasicRender"
            Tags
            {
                "LightMode"="UniversalForward"
            }

            Cull [_CullMode]
            Stencil{
                Ref [_StencilRef]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            Blend [_SrcBlendModeColor] [_DstBlendModeColor], [_SrcBlendModeAlpha] [_DstBlendModeAlpha]
            BlendOp [_BlendOp]
            ZWrite [_ZWrite]

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
            #pragma shader_feature_local _MAINLIGHT_SHADOWATTENUATION_ON
            #pragma shader_feature_local_fragment _NORMAL_MAP_ON
            #pragma shader_feature_local _SPECULAR_ON
            #pragma shader_feature_local _RIM_LIGHTING_ON
            
            #include "../../ShaderLibrary/AvatarGenshinPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "BackFacingOutline"
            Cull Front // Cull Front is a must for extra pass outline method
            ZWrite [_ZWrite]
            Tags
            {
                "LightMode"="SRPDefaultUnlit"
            }
            HLSLPROGRAM
            #pragma vertex BackFaceOutlineVertex
            #pragma fragment BackFaceOutlineFragment
            #pragma shader_feature_local _OUTLINE_CUSTOM_COLOR_ON

            // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
            #include "../../ShaderLibrary/AvatarGenshinOutlinePass.hlsl"

            ENDHLSL
        }


        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite [_ZWrite]
            ZTest LEqual
            ColorMask 0
            Cull [_CullMode]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            // Material keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            
            #pragma vertex ShadowPassVertex // 和後面的include 有關係
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite [_ZWrite]
            ColorMask 0
            Cull [_CullMode]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthOnlyVertex // 和後面的include 有關係
            #pragma fragment DepthOnlyFragment

            // Material keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite [_ZWrite]
            Cull [_CullMode]

            HLSLPROGRAM
            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5

            #pragma vertex DepthNormalsVertex // 和後面的include 有關係
            #pragma fragment DepthNormalsFragment

            // Material keywords
            #pragma shader_feature_local _NORMALMAP 
            #pragma shader_feature_local _PARALLAXMAP
            #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
}