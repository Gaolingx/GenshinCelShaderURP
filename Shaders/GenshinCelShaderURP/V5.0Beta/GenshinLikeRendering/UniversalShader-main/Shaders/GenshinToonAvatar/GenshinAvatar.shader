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

        [Header(Main Lighting)]
        _MainTex("Diffuse Texture", 2D) = "white" { }
        _ilmTex("ilm Texture", 2D) = "white" { }
        _RampTex("Ramp Texture", 2D) = "white" { }
        _BrightFac("Bright Factor", Float) = 0.99
        _GreyFac("Gray Factor", Float) = 1.08
        _DarkFac("Dark Factor", Float) = 0.55
        _RampAOLerp("Shadow AO Lerp", Range(0.0, 1.0)) = 0.5

        [Header(Indirect Lighting)]
        _IndirectLightFlattenNormal("Indirect light flatten normal (Default 0)", Range(0, 1)) = 0
        _IndirectLightIntensity("Indirect light intensity (Default 1)", Range(0, 2)) = 1
        _IndirectLightUsage("Indirect light color usage (Default 0.5)", Range(0, 1)) = 0.5

        [Header(Face Settings)]
        _FaceMap("Face SDF Texture", 2D) = "white" { }
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
        _BumpFactor("Bump Scale", Float) = 1.0
        [Normal] _NormalMap("Normal Map (Default black)", 2D) = "bump" { }

        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular ("Enable Specular (Default YES)", Float) = 1
        _MetalTex("Metal Texture", 2D) = "Gray" { }
        _MTMapBrightness("Metal Map Brightness", Range(0.0, 10.0)) = 3.0
        _MTShininess("Metal Shininess", Range(0.0, 100.0)) = 90.0
        _MTSpecularScale("Metal Specular Scale", Range(0.0, 100.0)) = 15.0
        _Shininess("Shininess", Range(5.0, 20.0)) = 10.0
        _NonMetalSpecArea("Non-metal Spcular Area", Range(0.0, 1.0)) = 0.0
        _SpecMulti("Specular Multiplier", Range(0.0, 10)) = 0.2

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)", Float) = 1
        _ModelScale("Model Scale (Default 1)", Float) = 1
        _RimIntensity("Rim Intensity (Front Face)", Float) = 0.5
        _RimIntensityBackFace("Rim Intensity (Back Face)", Float) = 0
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimWidth("Rim Width", Float) = 1
        _RimDark("Rim Darken Value", Range(0, 1)) = 0.5
        _RimEdgeSoftness("Rim Edge Softness", Float) = 0.05

        [Header(Emission)]
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)", Float) = 0
        _EmissionScaler("Emission Scaler", Range(1.0, 10.0)) = 5.0

        [Header(Outline)]
        [Toggle(_OUTLINE_ON)] _UseOutline("Use outline (Default YES)", Float) = 1
        _OutlineWidthAdjustScale("Outline Width Adjust Scale", Range(0.0, 1.0)) = 0.1
        [Toggle(_OUTLINE_CUSTOM_COLOR_ON)] _UseCustomOutlineCol("Use Custom outline Color (Default NO)", Float) = 0
        [ToggleUI] _IsFace("Use Clip Pos With ZOffset (face material)", Float) = 0
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0, 1)) = 0.0001
        _CustomOutlineCol("Custom Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineColor1("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor2("Outline Color 2", Color) = (0.1, 0.1, 0.1, 1.0)
        _OutlineColor3("Outline Color 3", Color) = (0.2, 0.2, 0.2, 1.0)
        _OutlineColor4("Outline Color 4", Color) = (0.3, 0.3, 0.3, 1.0)
        _OutlineColor5("Outline Color 5", Color) = (0.4, 0.4, 0.4, 1.0)
        [KeywordEnum(Null, VertexColor, NormalTexture)] _UseSmoothNormal("Use Smooth Normal From", Float) = 0.0
        _SmoothNormalTex("SmoothNormal Texture", 2D) = "white" { }

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
            #pragma shader_feature_local _ _MAINTEXALPHAUSE_NONE _MAINTEXALPHAUSE_FLICKER _MAINTEXALPHAUSE_EMISSION _MAINTEXALPHAUSE_ALPHATEST
            #pragma shader_feature_local _ _RENDERTYPE_BODY _RENDERTYPE_FACE
            #pragma shader_feature_fragment _ _USEFACELIGHTMAPCHANNEL_R _USEFACELIGHTMAPCHANNEL_A
            #pragma shader_feature_local _EMISSION_ON
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
            #pragma shader_feature_local _ _USESMOOTHNORMAL_VERTEXCOLOR _USESMOOTHNORMAL_NORMALTEXTURE _USESMOOTHNORMAL_NULL
            #pragma shader_feature_local _OUTLINE_ON
            #pragma shader_feature_local _OUTLINE_CUSTOM_COLOR_ON
            
            #if _OUTLINE_ON
            
                // all shader logic written inside this .hlsl, remember to write all #define BEFORE writing #include
                #include "../../ShaderLibrary/AvatarGenshinOutlinePass.hlsl"
            #else
                struct Attributes {};
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                };
                Varyings BackFaceOutlineVertex(Attributes input)
                {
                    return (Varyings)0;
                }
                float4 BackFaceOutlineFragment(Varyings input) : SV_TARGET
                {
                    return 0;
                }
            #endif

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