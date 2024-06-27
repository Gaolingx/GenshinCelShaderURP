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
TEXTURE2D(_FaceShadowMap);
SAMPLER(sampler_FaceShadowMap);
TEXTURE2D(_FaceMapTex);
SAMPLER(sampler_FaceMapTex);
TEXTURE2D(_NormalMap);
SAMPLER(sampler_NormalMap);
TEXTURE2D(_RampTex);
SAMPLER(sampler_RampTex);
TEXTURE2D(_MTMap);
SAMPLER(sampler_MTMap);
TEXTURE2D(_MTSpecularRamp);
SAMPLER(sampler_MTSpecularRamp);

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
float _EmissionMixBaseColorFac;
float4 _EmissionTintColor;
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

// metal properties : 
float _MetalMaterial;
float _MTUseSpecularRamp;
float _MTMapTileScale;
float _MTMapBrightness;
float _MTShininess;
float _MTSpecularScale;
float _MTSpecularAttenInShadow;
float _MTSharpLayerOffset;
float4 _MTMapDarkColor;
float4 _MTMapLightColor;
float4 _MTShadowMultiColor;
float4 _MTSpecularColor;
float4 _MTSharpLayerColor;

// specular properties :
float _SpecularHighlights;
float _UseToonSpecular;
float _Shininess;
float _Shininess2;
float _Shininess3;
float _Shininess4;
float _Shininess5;
float _SpecMulti;
float _SpecMulti2;
float _SpecMulti3;
float _SpecMulti4;
float _SpecMulti5;
float4 _SpecularColor;

//RimLight
float _RimLightThickness;
float _RimLightIntensity;
float _RimThreshold;
float4 _CustomOutlineCol;
float4 _RimColor;
float4 _RimColor1;
float4 _RimColor2;
float4 _RimColor3;
float4 _RimColor4;
float4 _RimColor5;

//Outline
float _EnableOutlineToggle;
float  _OutlineType;
float _FallbackOutlines;
float _UseFaceOutline;
float _OutlineWidth;
float _OutlineCorrectionWidth;
float _Scale;
float4 _OutlineColor1;
float4 _OutlineColor2;
float4 _OutlineColor3;
float4 _OutlineColor4;
float4 _OutlineColor5;
float4 _OutlineWidthAdjustScales;
float4 _OutlineWidthAdjustZs;
float  _MaxOutlineZOffset;

float _DebugValue01;
CBUFFER_END

#endif