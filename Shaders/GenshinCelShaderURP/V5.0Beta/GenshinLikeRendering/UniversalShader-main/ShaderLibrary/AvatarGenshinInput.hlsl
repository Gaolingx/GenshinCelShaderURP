#ifndef CUSTOM_AVATAR_GENSHIN_INPUT_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

///////////////////////////////////////////////////////////////////////////////////////
// CBUFFER and Uniforms 
// (you should put all uniforms of all passes inside this single UnityPerMaterial CBUFFER! else SRP batching is not possible!)
///////////////////////////////////////////////////////////////////////////////////////

// all sampler2D don't need to put inside CBUFFER 


TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);
TEXTURE2D(_ilmTex);
SAMPLER(sampler_ilmTex);
TEXTURE2D(_FaceMap);
SAMPLER(sampler_FaceMap);
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

// put all your uniforms(usually things inside .shader file's properties{}) inside this CBUFFER, in order to make SRP batcher compatible
// see -> https://blogs.unity3d.com/2019/02/28/srp-batcher-speed-up-your-rendering/
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

//Light
float _IndirectLightFlattenNormal;
float _IndirectLightIntensity;
float _IndirectLightUsage;

//NormalMap
float _BumpFactor;

//Ramp
float _RampIndex0;
float _RampIndex1;
float _RampIndex2;
float _RampIndex3;
float _RampIndex4;
float _BrightFac;
float _GreyFac;
float _DarkFac;

//Shadow
half4 _LightAreaColorTint;
float _RampAOLerp;
float _FaceShadowOffset;
half4 _DarkShadowColor;
half4 _CoolDarkShadowColor;
float _BrightAreaShadowFac;
float _FaceShadowTransitionSoftness;

//Specular
float _MTMapBrightness;
float _MTShininess;
float _MTSpecularScale;
float _Shininess;
float _NonMetalSpecArea;
float _SpecMulti;

//RimLight
float _ModelScale;
float _RimIntensity;
float _RimIntensityBackFace;
float4 _RimColor;
float _RimWidth;
float _RimDark;
float _RimEdgeSoftness;

//Outline
float _IsFace;
float _OutlineZOffset;
half4 _CustomOutlineCol;
half4 _OutlineColor1;
half4 _OutlineColor2;
half4 _OutlineColor3;
half4 _OutlineColor4;
half4 _OutlineColor5;
float _OutlineWidthAdjustScale;

float _DebugValue01;
CBUFFER_END

#endif