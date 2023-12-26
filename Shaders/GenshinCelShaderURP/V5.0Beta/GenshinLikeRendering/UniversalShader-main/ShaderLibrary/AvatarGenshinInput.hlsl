#ifndef CUSTOM_AVATAR_GENSHIN_INPUT_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"



TEXTURE2D(_HairShadowMask);
SAMPLER(sampler_HairShadowMask);

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_ilmTex);
SAMPLER(sampler_ilmTex);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_RampTex);
SAMPLER(sampler_RampTex);
TEXTURE2D(_MetalTex);
SAMPLER(sampler_MetalTex);

#if defined(_USESMOOTHNORMAL_NORMALTEXTURE)
TEXTURE2D(_SmoothNormalTex);
SAMPLER(sampler_SmoothNormalTex);
#endif

CBUFFER_START(UnityPerMaterial)

//General Controller
float _UseCoolShadowColorOrTex;
float _MainTexCutOff;
float _EmissionScaler;
float _FinalColorScaler;

float3 _FrontFaceTintColor;
float3 _BackFaceTintColor;
float _Alpha;
float _AlphaClip;

//Shadow
float _LightArea;
half4 _LightAreaColorTint;
float _RampCount;
float _ShadowRampWidth;
float _RampAOLerp;
float _HairShadowDistance;
float _FaceShadowOffset;
half4 _MainTexColoring;
half4 _DarkShadowColor;
half4 _CoolDarkShadowColor;
half4 _NeckColor;
float3 _DarkShadowColorTint;

//Specular
#if _SPECULAR_ON
float _MTMapBrightness;
float _MTShininess;
float _MTSpecularScale;
float _Shininess;
float _NonMetalSpecArea;
float _SpecMulti;
#endif

//RimLight
#if _RIM_LIGHTING_ON
float _RimLightWidth;
float _RimLightThreshold;
float _RimLightFadeout;
float3 _RimLightTintColor;
float _RimLightBrightness;
#endif
float _RimLightMixAlbedo;

//Outline
#if _OUTLINE_ON
float   _IsFace;
float   _OutlineZOffset;
half4 _CustomOutlineCol;
half4 _OutlineColor1;
half4 _OutlineColor2;
half4 _OutlineColor3;
half4 _OutlineColor4;
half4 _OutlineColor5;
float _OutlineWidthAdjustScale;
#endif

float _DebugValue01;
CBUFFER_END

#endif