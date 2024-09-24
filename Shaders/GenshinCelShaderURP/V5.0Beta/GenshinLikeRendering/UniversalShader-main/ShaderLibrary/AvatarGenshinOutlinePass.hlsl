#ifndef CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "../ShaderLibrary/AvatarShaderUtils.hlsl"

struct CharOutlineAttributes
{
    float4 positionOS     : POSITION;
    float4 color          : COLOR;
    float3 normalOS       : NORMAL;
    float4 tangentOS      : TANGENT;
    float2 uv1            : TEXCOORD0;
    float2 uv2            : TEXCOORD1;
    float2 packSmoothNormal : TEXCOORD2;
};

struct CharOutlineVaryings
{
    float4 positionCS     : SV_POSITION;
    float4 baseUV         : TEXCOORD0;
    float4 color          : COLOR;
    float3 normalWS       : TEXCOORD1;
    float3 positionWS     : TEXCOORD2;
    real   fogFactor      : TEXCOORD3;
};

float3 GetSmoothNormalWS(CharOutlineAttributes input)
{
    float3 smoothNormalOS = input.normalOS;

    #ifdef _OUTLINENORMALCHANNEL_NORMAL
        smoothNormalOS = input.normalOS;
    #elif _OUTLINENORMALCHANNEL_TANGENT
        smoothNormalOS = input.tangentOS.xyz;
    #elif _OUTLINENORMALCHANNEL_UV2
        float3 normalOS = normalize(input.normalOS);
        float3 tangentOS = normalize(input.tangentOS.xyz);
        float3 bitangentOS = normalize(cross(normalOS, tangentOS) * (input.tangentOS.w * GetOddNegativeScale()));
        float3 smoothNormalTS = UnpackNormalOctQuadEncode(input.packSmoothNormal);
        smoothNormalOS = mul(smoothNormalTS, float3x3(tangentOS, bitangentOS, normalOS));
    #endif

    return TransformObjectToWorldNormal(smoothNormalOS);
}

float GetOutlineWidth(float positionVS_Z)
{
    float fovFactor = 2.414 / UNITY_MATRIX_P[1].y;
    float z = abs(positionVS_Z * fovFactor);

    float4 params = _OutlineWidthParams;
    float k = saturate((z - params.x) / (params.y - params.x));
    float width = lerp(params.z, params.w, k);

    return 0.01 * _OutlineWidth * _OutlineScale * width;
}

float4 GetOutlinePosition(VertexPositionInputs vertexInput, float3 normalWS, half4 vertexColor)
{
    float z = vertexInput.positionVS.z;
    float width = GetOutlineWidth(z) * vertexColor.a;

    half3 normalVS = TransformWorldToViewNormal(normalWS);
    normalVS = SafeNormalize(half3(normalVS.xy, 0.0));

    float3 positionVS = vertexInput.positionVS;
    positionVS += 0.01 * _OutlineZOffset * SafeNormalize(positionVS);
    positionVS += width * normalVS;

    float4 positionCS = TransformWViewToHClip(positionVS);
    positionCS.xy += _ScreenOffset.zw * positionCS.w;

    return positionCS;
}

CharOutlineVaryings BackFaceOutlineVertex(CharOutlineAttributes input)
{
    CharOutlineVaryings output;

    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS);

    float3 smoothNormalWS = GetSmoothNormalWS(input);
    float4 positionCS = GetOutlinePosition(vertexPositionInput, smoothNormalWS, input.color);

    output.baseUV = CombineAndTransformDualFaceUV(input.uv1, input.uv2, 1);
    output.color = input.color;
    output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.normalWS = vertexNormalInput.normalWS;
    output.positionCS = positionCS;

    output.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return output;
}

half4 BackFaceOutlineFragment(CharOutlineVaryings input, FRONT_FACE_TYPE isFrontFace : FRONT_FACE_SEMANTIC) : SV_Target
{
    //根据ilmTexture的五个分组区分出五个不同颜色的描边区域
    half outlineColorMask = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.baseUV.xy).a;
    float material_id = materialID(outlineColorMask);

    float4 outline_colors[5] = 
    {
        _OutlineColor1, _OutlineColor2, _OutlineColor3, _OutlineColor4, _OutlineColor5
    };

    half3 finalOutlineColor = 0;
    #if _OUTLINE_CUSTOM_COLOR_ON
        finalOutlineColor = _CustomOutlineCol.rgb;
    #else
        finalOutlineColor = outline_colors[material_id - 1].xyz;
    #endif
    
    float alpha = _Alpha;

    float4 FinalColor = float4(finalOutlineColor, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);

    // Mix Fog
    real fogFactor = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactor);
    FinalColor.rgb = MixFog(FinalColor.rgb, fogFactor);

    return float4(FinalColor.rgb, 1);
}

#endif