Shader "GenshinCelShaderURP/V5.0Beta"
{
    Properties
    {
        [Header(General)]
        [KeywordEnum(Body, Face)]_RenderType("Render Type", float) = 0.0
        [KeywordEnum(R, A)]_UseFaceLightMapChannel("Use Face Lightmap Channel", float) = 1.0
        [Toggle]_UseCoolShadowColorOrTex("Use Cool Shadow", float) = 0.0
        [KeywordEnum(None,Flicker,Emission,AlphaTest)]_MainTexAlphaUse("Diffuse Texture Alpha Use", float) = 0.0
        _MainTexCutOff("Cut Off", Range(0.0, 1.0)) = 0.5
        [Toggle(_EMISSION_ON)] _UseEmission("Use emission (Default NO)",float) = 0
        _EmissionScaler("Emission Scaler", Range(1.0, 10.0)) = 5.0
        [Enum(UnityEngine.Rendering.CullMode)]_BasePassCullMode("Base Pass Cull Mode", Float) = 0.0
        _Alpha("Alpha (Default 1)", Range(0,1)) = 1
        _AlphaClip("Alpha clip (Default 0.333)", Range(0,1)) = 0.333

        [Header(Lighting)]
        _MainTex("Diffuse Texture", 2D) = "white"{}
        _ilmTex("ilm Texture", 2D) = "white"{}
        _RampTex("Ramp Texture", 2D) = "white"{}
        [Toggle]_UseRampLightAreaColor("Use Ramp Light Area Color", float) = 0.0
        _LightArea("Light Area", Range(0.0, 1.0)) = 0.55
        _LightAreaColorTint("Light Area Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
        _RampCount("Ramp Count", Int) = 3
        _ShadowRampWidth("Shadow Ramp Width", Range(0.0, 1.0)) = 1.0
        _HairShadowDistance("Hair Shadow Distance", Range(0.0, 1.0)) = 0.5
        _FaceShadowOffset ("Face Shadow Offset", range(-1.0, 1.0)) = 0.0
        _MainTexColoring("Main Texture Coloring", Color) = (1.0, 1.0, 1.0, 1.0)
        _DarkShadowColor("Dark Shadow Color Tint", Color) = (0.75, 0.75, 0.75, 1.0)
        _CoolDarkShadowColor("Cool Dark Shadow Color Tint", Color) = (0.5, 0.5, 0.65, 1.0)
        _NeckColor("Neck Color Tint", Color) = (0.75, 0.75, 0.75, 1.0)
        
        [Header(Specular)]
        [Toggle(_SPECULAR_ON)] _EnableSpecular ("Enable Specular (Default YES)", float) = 1
        _MetalTex("Metal Texture", 2D) = "Gray"{}
        _MTMapBrightness("Metal Map Brightness", Range(0.0, 10.0)) = 3.0
        _MTShininess("Metal Shininess", Range(0.0, 100.0)) = 90.0
        _MTSpecularScale("Metal Specular Scale", Range(0.0, 100.0)) = 15.0
        _Shininess("Shininess", Range(5.0, 20.0)) = 10.0
        _NonMetalSpecArea("Non-metal Spcular Area", Range(0.0, 1.0)) = 0.0
        _SpecMulti("Specular Multiplier", Range(0.0, 1.0)) = 0.2

        [Header(Rim Lighting)]
        [Toggle(_RIM_LIGHTING_ON)] _UseRimLight("Use Rim light (Default YES)",float) = 1
        _RimLightWidth("Rim light width (Default 1)",Range(0, 10)) = 1
        _RimLightThreshold("Rin light threshold (Default 0.05)",Range(-1, 1)) = 0.05
        _RimLightFadeout("Rim light fadeout (Default 1)",Range(0.01, 1)) = 1
        [HDR] _RimLightTintColor("Rim light tint colar (Default white)",Color) = (1,1,1)
        _RimLightBrightness("Rim light brightness (Default 1)",Range(0, 10)) = 1
        _RimLightMixAlbedo("Rim light mix albedo (Default 0.9)",Range(0, 1)) = 0.9

        [Header(Outline)]
        [Toggle(_OUTLINE_ON)] _UseOutline("Use outline (Default YES)", float ) = 1
        _OutlineWidthAdjustScale("Outline Width Adjust Scale", Range(0.0, 1.0)) = 1.0
        [Toggle(_OUTLINE_CUSTOM_COLOR_ON)] _UseCustomOutlineCol("Use Custom outline Color (Default NO)", float ) = 0
        [ToggleUI]_IsFace("Is Face? (please turn on if this is a face material)", Float) = 0
        _OutlineZOffset("_OutlineZOffset (View Space)", Range(0, 1)) = 0.0001
        _CustomOutlineCol("Custom Outline Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _OutlineColor1("Outline Color 1", Color) = (0.0, 0.0, 0.0, 1.0)
        _OutlineColor2("Outline Color 2", Color) = (0.1, 0.1, 0.1, 1.0)
        _OutlineColor3("Outline Color 3", Color) = (0.2, 0.2, 0.2, 1.0)
        _OutlineColor4("Outline Color 4", Color) = (0.3, 0.3, 0.3, 1.0)
        _OutlineColor5("Outline Color 5", Color) = (0.4, 0.4, 0.4, 1.0)
        [KeywordEnum(Null, VertexColor, NormalTexture)]_UseSmoothNormal("Use Smooth Normal From", float) = 0.0

        [Header(Debug)]
        _DebugValue01("Debug Value 0-1", Range(0.0, 1.0)) = 0.0

        [Header(Surface Options)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull (Default back)", Float) = 2
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendMode ("Cull (Default back)", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendMode ("Cull (Default back)", Float) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] _BlendOp ("Cull (Default back)", Float) = 0
        [Enum(Off,0, On,1)] _ZWrite("ZWrite (Default On)",Float) = 1
        _StencilRef ("Stencil reference (Default 0)",Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil comparison (Default disabled)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPassOp("Stencil pass comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFailOp("Stencil fail comparison (Default keep)",Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFailOp("Stencil z fail comparison (Default keep)",Int) = 0
    }
    SubShader
    {
        HLSLINCLUDE
        #include "../ShaderLibrary/AvatarGenshinInput.hlsl"
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
            Cull[_Cull]
            Stencil{
                Ref [_StencilRef]
                Comp [_StencilComp]
                Pass [_StencilPassOp]
                Fail [_StencilFailOp]
                ZFail [_StencilZFailOp]
            }
            Blend [_SrcBlendMode] [_DstBlendMode]
            BlendOp [_BlendOp]
            ZWrite [_ZWrite]

            Tags
            {
                "LightMode"="UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex GenshinStyleVertex
            #pragma fragment GenshinStyleFragment
            #pragma shader_feature_local _ _MAINTEXALPHAUSE_NONE _MAINTEXALPHAUSE_FLICKER _MAINTEXALPHAUSE_EMISSION _MAINTEXALPHAUSE_ALPHATEST
            #pragma shader_feature_local _ _RENDERTYPE_BODY _RENDERTYPE_FACE
            #pragma shader_feature_fragment _ _USEFACELIGHTMAPCHANNEL_R _USEFACELIGHTMAPCHANNEL_A
            #pragma shader_feature_local_fragment _USERAMPLIGHTAREACOLOR_ON
            #pragma shader_feature_local _EMISSION_ON
            #pragma shader_feature_local _SPECULAR_ON
            #pragma shader_feature_local _RIM_LIGHTING_ON
            
            #include "../ShaderLibrary/AvatarGenshinPass.hlsl"
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
                #include "../ShaderLibrary/AvatarGenshinOutlinePass.hlsl"
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
            Cull[_Cull]

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
            Cull[_Cull]

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
            Cull[_Cull]

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