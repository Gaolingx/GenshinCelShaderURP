#ifndef POST_PROCESS_GAUSSIAN_BLUR_PASS_INCLUDED
#define POST_PROCESS_GAUSSIAN_BLUR_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
float4 _MainTex_TexelSize;
float _BlurSize;
CBUFFER_END

struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv0 : TEXCOORD0;
    float4 uv12 : TEXCOORD1;
    float4 uv34 : TEXCOORD2;
};

Varyings GaussianBlurVerticalVertex(Attributes input)
{
    Varyings vertexOutput;
    vertexOutput.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    vertexOutput.uv0 = input.uv;
    vertexOutput.uv12.xy = input.uv + half2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
    vertexOutput.uv12.zw = input.uv - half2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
    vertexOutput.uv34.xy = input.uv + half2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
    vertexOutput.uv34.zw = input.uv - half2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
    return vertexOutput;
}

Varyings GaussianBlurHorizontalVertex(Attributes input)
{
    Varyings vertexOutput;
    vertexOutput.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    vertexOutput.uv0 = input.uv;
    vertexOutput.uv12.xy = input.uv + half2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
    vertexOutput.uv12.zw = input.uv - half2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
    vertexOutput.uv34.xy = input.uv + half2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
    vertexOutput.uv34.zw = input.uv - half2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
    return vertexOutput;
}

float4 GaussianBlurFragment(Varyings input) : SV_Target
{
    float2 uv[5] = {input.uv0, input.uv12.xy, input.uv12.zw, input.uv34.xy, input.uv34.zw};
    const float gaussianFactor[3] = {0.4026, 0.2442, 0.0545};
    float3 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[0]).rgb * gaussianFactor[0];
    for (int i = 1; i < 3; i++)
    {
        color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[i*2-1]).rgb * gaussianFactor[i];
        color += SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv[i*2]).rgb * gaussianFactor[i];
    }
    return float4(color, 1.0);
}

#endif
