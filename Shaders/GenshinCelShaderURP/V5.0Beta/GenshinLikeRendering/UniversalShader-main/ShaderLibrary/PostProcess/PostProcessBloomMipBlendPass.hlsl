#ifndef POST_PROCESS_MIP_BLEND_PASS_INCLUDED
#define POST_PROCESS_MIP_BLEND_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

TEXTURE2D(_BloomRT_1);
SAMPLER(sampler_BloomRT_1);
TEXTURE2D(_BloomRT_2);
SAMPLER(sampler_BloomRT_2);
TEXTURE2D(_BloomRT_3);
SAMPLER(sampler_BloomRT_3);
TEXTURE2D(_BloomRT_4);
SAMPLER(sampler_BloomRT_4);

CBUFFER_START(UnityPerMaterial)
float4 _BloomColorTint;
float4 _BloomMipIntensity;
float _BloomIntensity;
float _BloomScatter;
float _MipsCounts;
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

Varyings BloomBlendVertex(Attributes input)
{
    Varyings vertexOutput;
    vertexOutput.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    vertexOutput.uv = input.uv;
    return vertexOutput;
}

float4 BloomMipsBlendFragment(Varyings input) : SV_Target
{
    //Hard Codes, need To Improve. However, static branch!
    if (_MipsCounts == 1)
    {
        return SAMPLE_TEXTURE2D(_BloomRT_1, sampler_BloomRT_1, input.uv);
    }
    else if(_MipsCounts == 2)
    {
        float4 bloomRT1 = SAMPLE_TEXTURE2D(_BloomRT_1, sampler_BloomRT_1, input.uv);
        float4 bloomRT2 = SAMPLE_TEXTURE2D(_BloomRT_2, sampler_BloomRT_2, input.uv);
        return lerp(bloomRT1 * _BloomMipIntensity.x, bloomRT2 * _BloomMipIntensity.y, _BloomScatter);
    }
    else if (_MipsCounts == 3)
    {
        float4 bloomRT1 = SAMPLE_TEXTURE2D(_BloomRT_1, sampler_BloomRT_1, input.uv);
        float4 bloomRT2 = SAMPLE_TEXTURE2D(_BloomRT_2, sampler_BloomRT_2, input.uv);
        float4 bloomRT3 = SAMPLE_TEXTURE2D(_BloomRT_3, sampler_BloomRT_3, input.uv);
        return lerp(
            lerp(bloomRT1 * _BloomMipIntensity.x, bloomRT2 * _BloomMipIntensity.y, _BloomScatter),
            bloomRT3 * _BloomMipIntensity.z,
            _BloomScatter);
    }
    else if (_MipsCounts == 4)
    {
        float4 bloomRT1 = SAMPLE_TEXTURE2D(_BloomRT_1, sampler_BloomRT_1, input.uv);
        float4 bloomRT2 = SAMPLE_TEXTURE2D(_BloomRT_2, sampler_BloomRT_2, input.uv);
        float4 bloomRT3 = SAMPLE_TEXTURE2D(_BloomRT_3, sampler_BloomRT_3, input.uv);
        float4 bloomRT4 = SAMPLE_TEXTURE2D(_BloomRT_4, sampler_BloomRT_4, input.uv);
        return lerp(
            lerp(
                lerp(bloomRT1 * _BloomMipIntensity.x, bloomRT2 * _BloomMipIntensity.y, _BloomScatter),
                bloomRT3 * _BloomMipIntensity.z, _BloomScatter),
                bloomRT4 * _BloomMipIntensity.w,
                _BloomScatter);

    }
    else
    {
        return float4(0.0, 0.0, 0.0, 0.0);
    }
}

float4 BloomFinalBlendFragment(Varyings input) : SV_Target
{
    float4 mainTexCol = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
    float4 bloomCol = SAMPLE_TEXTURE2D(_BloomRT_1, sampler_BloomRT_1, input.uv) * _BloomColorTint;
    return mainTexCol + bloomCol * _BloomIntensity;
}

#endif
