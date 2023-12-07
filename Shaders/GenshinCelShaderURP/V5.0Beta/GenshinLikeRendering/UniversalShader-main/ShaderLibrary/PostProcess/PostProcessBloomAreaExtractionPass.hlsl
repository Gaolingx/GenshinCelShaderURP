#ifndef POST_PROCESS_BLOOM_AREA_EXTRACTION_PASS_INCLUDED
#define POST_PROCESS_BLOOM_AREA_EXTRACTION_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
float _ExtractThreshold;
CBUFFER_END

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv : TEXCOORD0;
};

Varyings BloomAreaExtractionVertex(Attributes input)
{
    Varyings output;
    output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    output.uv = input.uv;
    return output;
}

float4 BloomAreaExtractionFragment(Varyings input) : SV_Target
{
    float4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    float4 bloomAreaColor = 0.0;
    
    #if defined(_EXTRACTBYLUMINANCE)
    float luminance = 0.2126 * mainTexCol.r + 0.7152 * mainTexCol.g + 0.0722 * mainTexCol.b;
    float mask = max(luminance - _ExtractThreshold, 0.0);
    bloomAreaColor = mainTexCol * mask;
    #elif defined(_EXTRACTBYCOLOR)
    bloomAreaColor = max(mainTexCol - _ExtractThreshold, 0.0);
    #else
    bloomAreaColor = mainTexCol;
    #endif

    return bloomAreaColor;
}

#endif