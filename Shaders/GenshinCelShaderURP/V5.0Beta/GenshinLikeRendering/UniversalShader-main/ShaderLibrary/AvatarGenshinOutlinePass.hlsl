#ifndef CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED
#define CUSTOM_AVATAR_GENSHIN_OUTLINE_PASS_INCLUDED

#include "../ShaderLibrary/AvatarGenshinInput.hlsl"
#include "../ShaderLibrary/NiloZOffset.hlsl"

struct CharOutlineAttributes
{
    float3 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
    float2 baseUV       : TEXCOORD0;
    float2 addUV        : TEXCOORD1;
    float2 packSmoothNormal : TEXCOORD2;
};

struct CharOutlineVaryings
{
    float4 positionCS : SV_POSITION;
    float3 positionVS : TEXCOORD0;
    float3 positionWS : TEXCOORD1;
    float4 positionNDC : TEXCOORD2;
    float2 baseUV : TEXCOORD3;
    float2 addUV : TEXCOORD4;
    half3 color : TEXCOORD5;
    half3 normalWS : TEXCOORD6;
    half3 tangentWS : TEXCOORD7;
    half3 bitangentWS : TEXCOORD8;

    half3 sh : TEXCOORD9;

    float2 packSmoothNormal : TEXCOORD10;
    float fogFactor : TEXCOORD11;
};

void DoClipTestToTargetAlphaValue(float alpha, float alphaTestThreshold) 
{
    clip(alpha - alphaTestThreshold);
}

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

float CalculateExtendWidthWS(float3 positionWS, float3 extendVectorWS, float extendWS, float minExtendSS, float maxExtendSS)
{
    float4 positionCS = TransformWorldToHClip(positionWS);
    float4 extendPositionCS = TransformWorldToHClip(positionWS + extendVectorWS * extendWS);

    float2 delta = extendPositionCS.xy / extendPositionCS.w - positionCS.xy / positionCS.w;
    delta *= GetScaledScreenParams().xy / GetScaledScreenParams().y * 1080.0f;

    const float extendLen = length(delta);
    float width = extendWS * min(1.0, maxExtendSS / extendLen) * max(1.0, minExtendSS / extendLen);

    return width;
}

float3 ExtendOutline(float3 positionWS, float3 smoothNormalWS, float width, float widthMin, float widthMax)
{
    float offsetLen = CalculateExtendWidthWS(positionWS, smoothNormalWS, width, widthMin, widthMax);

    return positionWS + smoothNormalWS * offsetLen;
}


CharOutlineVaryings BackFaceOutlineVertex(CharOutlineAttributes input)
{
    VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 smoothNormalWS = GetSmoothNormalWS(input);
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);

    float outlineWidth = input.color.a;
    
    positionWS = ExtendOutline(positionWS, smoothNormalWS,
        _OutlineWidth * outlineWidth, _OutlineWidthMin * outlineWidth, _OutlineWidthMax * outlineWidth);

    float3 positionVS = TransformWorldToView(positionWS);
    float4 positionCS = TransformWorldToHClip(positionWS);

    positionCS = NiloGetNewClipPosWithZOffset(positionCS, _OutlineZOffset + 0.03 * _IsFace);

    CharOutlineVaryings output = (CharOutlineVaryings)0;
    output.positionCS = positionCS;
    output.positionVS = positionVS;
    output.positionWS = positionWS;
    //output.positionNDC = positionNDC;
    output.baseUV = input.baseUV;
    output.color = input.color.rgb;
    output.normalWS = normalInput.normalWS;
    output.tangentWS = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;

    output.sh = 0;
    output.packSmoothNormal = input.packSmoothNormal;

    output.fogFactor = ComputeFogFactor(vertexPositionInput.positionCS.z);

    return output;
}

half4 BackFaceOutlineFragment(CharOutlineVaryings input) : SV_Target
{
    //根据ilmTexture的五个分组区分出五个不同颜色的描边区域
    half outlineColorMask = SAMPLE_TEXTURE2D(_ilmTex, sampler_ilmTex, input.baseUV).a;
    half areaMask1 = step(0.003, outlineColorMask) - step(0.35, outlineColorMask);
    half areaMask2 = step(0.35, outlineColorMask) - step(0.55, outlineColorMask);
    half areaMask3 = step(0.55, outlineColorMask) - step(0.75, outlineColorMask);
    half areaMask4 = step(0.75, outlineColorMask) - step(0.95, outlineColorMask);
    half areaMask5 = step(0.95, outlineColorMask);

    half3 finalOutlineColor = 0;
    #if _OUTLINE_CUSTOM_COLOR_ON
        finalOutlineColor = _CustomOutlineCol.rgb;
    #else
        finalOutlineColor = (1.0 - (areaMask1 + areaMask2 + areaMask3 + areaMask4 + areaMask5)) * _OutlineColor1.rgb + areaMask2 * _OutlineColor2.rgb + areaMask3 * _OutlineColor3.rgb + areaMask4 * _OutlineColor4.rgb + areaMask5 * _OutlineColor5.rgb;
    #endif
    
    float alpha = _Alpha;

    float4 FinalColor = float4(finalOutlineColor, alpha);
    DoClipTestToTargetAlphaValue(FinalColor.a, _AlphaClip);
    FinalColor.rgb = MixFog(FinalColor.rgb, input.fogFactor);

    return float4(FinalColor.rgb, 1);
}

#endif